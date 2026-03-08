//
//  EditorDocument.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/7/2026.
//

import Configuration
import Foundation

/// A working copy model that tracks staged editor overrides with undo/redo support.
///
/// `EditorDocument` maintains a working copy of configuration overrides separate from the committed state in
/// ``EditorOverrideProvider``. Changes are staged in the working copy and only applied to the provider on
/// ``save()``. The document supports undo/redo for all mutations via an `UndoManager`.
@MainActor @Observable
final class EditorDocument {
    /// The editor override provider that this document commits to on save.
    private let provider: EditorOverrideProvider

    /// The undo manager for registering undo/redo actions, if any.
    private let undoManager: UndoManager?

    /// The committed baseline, snapshotted from the provider at init.
    private var baseline: [ConfigKey: ConfigContent]

    /// The working copy of overrides.
    private(set) var workingCopy: [ConfigKey: ConfigContent]


    /// Creates a new editor document.
    ///
    /// The document's working copy and baseline are initialized from the provider's current overrides.
    ///
    /// - Parameters:
    ///   - provider: The editor override provider to commit to on save.
    ///   - undoManager: An optional undo manager for registering undo/redo actions.
    init(provider: EditorOverrideProvider, undoManager: UndoManager? = nil) {
        self.provider = provider
        self.undoManager = undoManager
        let currentOverrides = provider.overrides
        self.baseline = currentOverrides
        self.workingCopy = currentOverrides
    }
}


// MARK: - Working Copy

extension EditorDocument {
    /// Returns the override value for the given key in the working copy.
    ///
    /// - Parameter key: The configuration key to look up.
    /// - Returns: The override content, or `nil` if no override exists.
    func override(forKey key: ConfigKey) -> ConfigContent? {
        workingCopy[key]
    }


    /// Whether the working copy contains an override for the given key.
    ///
    /// - Parameter key: The configuration key to check.
    /// - Returns: `true` if the working copy has an override for the key.
    func hasOverride(forKey key: ConfigKey) -> Bool {
        workingCopy[key] != nil
    }


    /// Sets an override in the working copy.
    ///
    /// If an undo manager is set, an undo action is registered that restores the previous value (or removes the
    /// override if there was none).
    ///
    /// - Parameters:
    ///   - content: The override content value.
    ///   - key: The configuration key to override.
    func setOverride(_ content: ConfigContent, forKey key: ConfigKey) {
        let previousContent = workingCopy[key]
        workingCopy[key] = content
        registerUndoForSet(previousContent: previousContent, key: key)
    }


    /// Removes the override for the given key from the working copy.
    ///
    /// If an undo manager is set and an override existed, an undo action is registered that restores the previous
    /// value.
    ///
    /// - Parameter key: The configuration key whose override should be removed.
    func removeOverride(forKey key: ConfigKey) {
        let previousContent = workingCopy.removeValue(forKey: key)
        if let previousContent {
            registerUndoForRemove(previousContent: previousContent, key: key)
        }
    }


    /// Removes all overrides from the working copy.
    ///
    /// If an undo manager is set and overrides existed, a single undo action is registered that restores all
    /// previous overrides.
    func removeAllOverrides() {
        let previousWorkingCopy = workingCopy
        workingCopy.removeAll()

        if !previousWorkingCopy.isEmpty {
            registerUndoForRemoveAll(previousWorkingCopy: previousWorkingCopy)
        }
    }
}


// MARK: - Dirty Tracking

extension EditorDocument {
    /// Whether the working copy differs from the committed baseline.
    var isDirty: Bool {
        workingCopy != baseline
    }


    /// The set of keys that differ between the working copy and the committed baseline.
    ///
    /// This includes keys that were added, removed, or changed relative to the baseline.
    var changedKeys: Set<ConfigKey> {
        var changed = Set<ConfigKey>()

        // Keys in working copy that are new or changed
        for (key, content) in workingCopy where baseline[key] != content {
            changed.insert(key)
        }

        // Keys in baseline that were removed from working copy
        for key in baseline.keys where workingCopy[key] == nil {
            changed.insert(key)
        }

        return changed
    }
}


// MARK: - Save

extension EditorDocument {
    /// Saves the working copy to the editor override provider and persists to UserDefaults.
    ///
    /// This computes the delta between the working copy and baseline, updates the provider to match the working
    /// copy, persists the overrides, and resets the baseline to match the working copy.
    ///
    /// - Returns: The set of keys that changed relative to the previous committed state.
    @discardableResult
    func save() -> Set<ConfigKey> {
        let changed = changedKeys
        baseline = workingCopy

        // Update the provider to match the working copy
        provider.removeAllOverrides()
        for (key, content) in workingCopy {
            provider.setOverride(content, forKey: key)
        }
        provider.persist(to: UserDefaults(suiteName: EditorOverrideProvider.suiteName)!)

        return changed
    }
}


// MARK: - Undo Registration

extension EditorDocument {
    /// Registers an undo action for a `setOverride` call.
    private func registerUndoForSet(previousContent: ConfigContent?, key: ConfigKey) {
        guard let undoManager else { return }

        if let previousContent {
            undoManager.registerUndo(withTarget: self) { document in
                document.setOverride(previousContent, forKey: key)
            }
        } else {
            undoManager.registerUndo(withTarget: self) { document in
                document.removeOverride(forKey: key)
            }
        }
    }


    /// Registers an undo action for a `removeOverride` call.
    private func registerUndoForRemove(previousContent: ConfigContent, key: ConfigKey) {
        guard let undoManager else { return }

        undoManager.registerUndo(withTarget: self) { document in
            document.setOverride(previousContent, forKey: key)
        }
    }


    /// Registers an undo action for a `removeAllOverrides` call.
    private func registerUndoForRemoveAll(previousWorkingCopy: [ConfigKey: ConfigContent]) {
        guard let undoManager else { return }

        undoManager.registerUndo(withTarget: self) { document in
            let currentWorkingCopy = document.workingCopy
            document.workingCopy = previousWorkingCopy
            document.registerUndoForRemoveAll(previousWorkingCopy: currentWorkingCopy)
        }
    }
}
