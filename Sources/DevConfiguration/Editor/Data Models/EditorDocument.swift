//
//  EditorDocument.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/9/2026.
//

import Configuration
import Foundation
import Synchronization

/// The central domain model for the configuration variable editor.
///
/// `EditorDocument` is the single source of truth for the editor UI. It owns provider snapshots, the working copy of
/// editor overrides, value resolution, dirty tracking, and save/undo/redo. Views and view models query the document
/// rather than providers directly.
///
/// On initialization, the document:
/// 1. Snapshots all providers into an ordered array of ``ProviderEditorSnapshot`` values
/// 2. Builds a final "Default" snapshot from registered variable default contents
/// 3. Initializes the working copy from the editor override provider's current overrides
///
/// The document watches each provider for snapshot changes and updates its corresponding ``ProviderEditorSnapshot``
/// automatically.
@MainActor
@Observable
final class EditorDocument {
    /// The result of resolving a configuration variable's value.
    struct ResolvedValue {
        /// The resolved content value.
        let content: ConfigContent

        /// The display name of the provider that owns this value.
        let providerDisplayName: String

        /// The index of the owning provider, used for color assignment.
        ///
        /// This is `nil` when the working copy owns the value.
        let providerIndex: Int?
    }


    /// The registered variables, keyed by their configuration key.
    let registeredVariables: [ConfigKey: RegisteredConfigVariable]

    /// The editor override provider.
    private let editorOverrideProvider: EditorOverrideProvider

    /// The undo manager used for working copy changes.
    let undoManager: UndoManager

    /// The display name of the editor override provider.
    let workingCopyDisplayName: String

    /// The ordered provider snapshots, including real providers and the trailing "Default" snapshot.
    private(set) var providerSnapshots: [ProviderEditorSnapshot]

    /// The working copy of editor overrides.
    private(set) var workingCopy: [ConfigKey: ConfigContent]

    /// The baseline overrides at the time of the last save, used for dirty tracking.
    private var baseline: [ConfigKey: ConfigContent]

    /// The task that watches providers for snapshot changes, stored in a `Mutex` so it can be cancelled from `deinit`.
    private let watchTask = Mutex<Task<Void, Never>?>(nil)


    /// Creates a new editor document.
    ///
    /// - Parameters:
    ///   - editorOverrideProvider: The editor override provider that stores the working copy.
    ///   - workingCopyDisplayName: The display name for the working copy in the UI.
    ///   - namedProviders: The reader's named providers, excluding the editor override provider.
    ///   - registeredVariables: The registered variables to display in the editor.
    ///   - undoManager: The undo manager for working copy changes.
    init(
        editorOverrideProvider: EditorOverrideProvider,
        workingCopyDisplayName: String,
        namedProviders: [NamedConfigProvider],
        registeredVariables: [RegisteredConfigVariable],
        undoManager: UndoManager
    ) {
        self.editorOverrideProvider = editorOverrideProvider
        self.workingCopyDisplayName = workingCopyDisplayName
        self.undoManager = undoManager

        // Build registered variables dictionary
        var registeredVariablesByKey: [ConfigKey: RegisteredConfigVariable] = [:]
        for variable in registeredVariables {
            registeredVariablesByKey[variable.key] = variable
        }
        self.registeredVariables = registeredVariablesByKey

        // Snapshot real providers
        var snapshots: [ProviderEditorSnapshot] = []
        for (index, namedProvider) in namedProviders.enumerated() {
            let snapshot = namedProvider.provider.snapshot()
            var values: [ConfigKey: ConfigContent] = [:]
            for variable in registeredVariables {
                let preferredType = variable.defaultContent.configType
                if let content = snapshot.configContent(forKey: variable.key, preferredType: preferredType) {
                    values[variable.key] = content
                }
            }

            snapshots.append(
                ProviderEditorSnapshot(
                    displayName: namedProvider.displayName,
                    index: index,
                    values: values
                )
            )
        }

        // Build "Default" snapshot from registered variable defaults
        let defaultIndex = namedProviders.count
        var defaultValues: [ConfigKey: ConfigContent] = [:]
        for variable in registeredVariables {
            defaultValues[variable.key] = variable.defaultContent
        }

        snapshots.append(
            ProviderEditorSnapshot(
                displayName: localizedString("editor.defaultProviderName"),
                index: defaultIndex,
                values: defaultValues
            )
        )

        self.providerSnapshots = snapshots

        // Initialize working copy and baseline from current overrides
        let currentOverrides = editorOverrideProvider.overrides
        self.workingCopy = currentOverrides
        self.baseline = currentOverrides

        // Start watching providers
        startWatching(namedProviders: namedProviders, registeredVariables: registeredVariables)
    }


    deinit {
        watchTask.withLock { $0?.cancel() }
    }
}


// MARK: - Provider Watching

extension EditorDocument {
    /// Starts watching providers for snapshot changes.
    private func startWatching(
        namedProviders: [NamedConfigProvider],
        registeredVariables: [RegisteredConfigVariable]
    ) {
        guard !namedProviders.isEmpty else {
            return
        }

        let task = Task {
            await withTaskGroup(of: Void.self) { [weak self] group in
                for (index, namedProvider) in namedProviders.enumerated() {
                    let provider = namedProvider.provider
                    group.addTask { [weak self] in
                        guard let self else {
                            return
                        }

                        do {
                            try await provider.watchSnapshot { updates in
                                for await snapshot in updates {
                                    guard !Task.isCancelled else {
                                        return
                                    }

                                    var values: [ConfigKey: ConfigContent] = [:]
                                    for variable in registeredVariables {
                                        if let content = snapshot.configContent(
                                            forKey: variable.key,
                                            preferredType: variable.defaultContent.configType
                                        ) {
                                            values[variable.key] = content
                                        }
                                    }

                                    await updateProviderSnapshot(at: index, values: values)
                                }
                            }
                        } catch {
                            // Provider watching ended; nothing to do
                        }
                    }
                }

                await group.waitForAll()
            }
        }

        watchTask.withLock { $0 = task }
    }


    /// Updates the values in the provider snapshot at the given index.
    private func updateProviderSnapshot(at index: Int, values: [ConfigKey: ConfigContent]) {
        providerSnapshots[index].values = values
    }
}


// MARK: - Value Resolution

extension EditorDocument {
    /// Resolves the winning value for the given configuration key.
    ///
    /// Resolution order: working copy first, then provider snapshots (including defaults) in order. A snapshot's value
    /// wins only if its ``ConfigContent/configType`` matches the registered variable's expected content type.
    ///
    /// - Parameter key: The configuration key to resolve.
    /// - Returns: The resolved value, or `nil` if no value is found.
    func resolvedValue(forKey key: ConfigKey) -> ResolvedValue? {
        guard let registeredVariable = registeredVariables[key] else { return nil }
        let expectedType = registeredVariable.defaultContent.configType

        // Check working copy first
        if let content = workingCopy[key], content.configType == expectedType {
            return ResolvedValue(
                content: content,
                providerDisplayName: workingCopyDisplayName,
                providerIndex: nil
            )
        }

        // Check provider snapshots in order
        for snapshot in providerSnapshots {
            if let content = snapshot.values[key], content.configType == expectedType {
                return ResolvedValue(
                    content: content,
                    providerDisplayName: snapshot.displayName,
                    providerIndex: snapshot.index
                )
            }
        }

        return nil
    }


    /// Returns all provider values for the given configuration key.
    ///
    /// Each entry includes the provider's display name, index, value string, whether it is the active winner, and
    /// whether its content type matches the registered variable's expected type.
    ///
    /// - Parameter key: The configuration key to query.
    /// - Returns: An array of ``ProviderValue`` instances for providers that have a value for the key.
    func providerValues(forKey key: ConfigKey) -> [ProviderValue] {
        guard let registeredVariable = registeredVariables[key] else { return [] }
        let expectedType = registeredVariable.defaultContent.configType
        let resolved = resolvedValue(forKey: key)

        var result: [ProviderValue] = []

        // Include working copy if it has a value
        if let content = workingCopy[key] {
            let isActive = resolved?.providerIndex == nil
            result.append(
                ProviderValue(
                    providerName: workingCopyDisplayName,
                    providerIndex: nil,
                    isActive: isActive,
                    valueString: content.displayString,
                    contentTypeMatches: content.configType == expectedType
                )
            )
        }

        // Include snapshots that have a value
        for snapshot in providerSnapshots {
            if let content = snapshot.values[key] {
                let isActive = resolved?.providerIndex == snapshot.index
                result.append(
                    ProviderValue(
                        providerName: snapshot.displayName,
                        providerIndex: snapshot.index,
                        isActive: isActive,
                        valueString: content.displayString,
                        contentTypeMatches: content.configType == expectedType
                    )
                )
            }
        }

        return result
    }
}


// MARK: - Working Copy

extension EditorDocument {
    /// Whether the working copy has an override for the given key.
    func hasOverride(forKey key: ConfigKey) -> Bool {
        workingCopy[key] != nil
    }


    /// Returns the override content for the given key, if any.
    func override(forKey key: ConfigKey) -> ConfigContent? {
        workingCopy[key]
    }


    /// Sets an override value in the working copy.
    ///
    /// If the new content is the same as the existing override, no change is made.
    ///
    /// - Parameters:
    ///   - content: The override content value.
    ///   - key: The configuration key to override.
    func setOverride(_ content: ConfigContent, forKey key: ConfigKey) {
        let oldContent = workingCopy[key]
        guard oldContent != content else { return }

        workingCopy[key] = content

        undoManager.registerUndo(withTarget: self) { document in
            if let oldContent {
                document.setOverride(oldContent, forKey: key)
            } else {
                document.removeOverride(forKey: key)
            }
        }
    }


    /// Removes the override for the given key from the working copy.
    ///
    /// If no override exists for the key, no change is made.
    ///
    /// - Parameter key: The configuration key whose override should be removed.
    func removeOverride(forKey key: ConfigKey) {
        guard let oldContent = workingCopy.removeValue(forKey: key) else {
            return
        }

        undoManager.registerUndo(withTarget: self) { document in
            document.setOverride(oldContent, forKey: key)
        }
    }


    /// Removes all overrides from the working copy.
    func removeAllOverrides() {
        let oldOverrides = workingCopy
        guard !oldOverrides.isEmpty else {
            return
        }

        workingCopy.removeAll()

        undoManager.registerUndo(withTarget: self) { document in
            for (key, content) in oldOverrides {
                document.setOverride(content, forKey: key)
            }
        }
    }
}


// MARK: - Dirty Tracking and Save

extension EditorDocument {
    /// Whether the working copy has unsaved changes.
    var isDirty: Bool {
        workingCopy != baseline
    }


    /// The keys whose overrides have changed since the last save.
    var changedKeys: Set<ConfigKey> {
        var keys = Set<ConfigKey>()

        for (key, content) in workingCopy where baseline[key] != content {
            keys.insert(key)
        }

        for key in baseline.keys where workingCopy[key] == nil {
            keys.insert(key)
        }

        return keys
    }


    /// Commits the working copy to the editor override provider and persists the changes.
    ///
    /// After saving, the baseline is updated to match the working copy and the dirty state is reset.
    func save() {
        // Determine what changed
        let currentKeys = Set(workingCopy.keys)
        let baselineKeys = Set(baseline.keys)

        // Remove overrides that were deleted
        for key in baselineKeys.subtracting(currentKeys) {
            editorOverrideProvider.removeOverride(forKey: key)
        }

        // Set overrides that were added or changed
        for (key, content) in workingCopy {
            editorOverrideProvider.setOverride(content, forKey: key)
        }

        // Persist
        editorOverrideProvider.persist()

        // Update baseline
        baseline = workingCopy
    }
}
