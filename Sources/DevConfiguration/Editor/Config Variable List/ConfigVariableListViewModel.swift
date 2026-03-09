//
//  ConfigVariableListViewModel.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/8/2026.
//

#if canImport(SwiftUI)

import Configuration
import Foundation

/// The concrete list view model for the configuration variable editor.
///
/// `ConfigVariableListViewModel` owns an ``EditorDocument`` and provides a filtered, sorted list of
/// ``VariableListItem`` values for display. It resolves which provider owns each variable's value by querying
/// providers in order, delegates save/cancel/undo/redo to the document and undo manager, and creates detail view
/// models for individual variables.
@MainActor @Observable
final class ConfigVariableListViewModel: ConfigVariableListViewModeling {
    /// The editor document managing the working copy.
    private let document: EditorDocument

    /// The registered variables from the reader, keyed by configuration key.
    private let registeredVariables: [ConfigKey: RegisteredConfigVariable]

    /// The reader's named providers, queried in order for value resolution.
    private let namedProviders: [NamedConfigProvider]

    /// The undo manager for the editor session.
    private let undoManager: UndoManager


    /// The current search text used to filter the variable list.
    var searchText = ""


    /// Creates a new list view model.
    ///
    /// - Parameters:
    ///   - document: The editor document managing the working copy.
    ///   - registeredVariables: The registered variables from the reader.
    ///   - namedProviders: The reader's named providers, queried in order for value resolution.
    ///   - undoManager: The undo manager for the editor session.
    init(
        document: EditorDocument,
        registeredVariables: [ConfigKey: RegisteredConfigVariable],
        namedProviders: [NamedConfigProvider],
        undoManager: UndoManager
    ) {
        self.document = document
        self.registeredVariables = registeredVariables
        self.namedProviders = namedProviders
        self.undoManager = undoManager
    }


    var variables: [VariableListItem] {
        let items = registeredVariables.values.map { variable in
            let (content, providerName, providerIndex) = resolvedValue(for: variable)
            return VariableListItem(
                key: variable.key,
                displayName: variable.displayName ?? variable.key.description,
                currentValue: content.displayString,
                providerName: providerName,
                providerIndex: providerIndex,
                isSecret: variable.isSecret,
                hasOverride: document.hasOverride(forKey: variable.key),
                editorControl: variable.editorControl
            )
        }

        let filtered =
            searchText.isEmpty
            ? items
            : items.filter { item in
                item.displayName.localizedStandardContains(searchText)
                    || item.key.description.localizedStandardContains(searchText)
                    || item.currentValue.localizedStandardContains(searchText)
                    || item.providerName.localizedStandardContains(searchText)
            }

        return filtered.sorted { (lhs, rhs) in
            lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
        }
    }


    var isDirty: Bool {
        document.isDirty
    }


    var canUndo: Bool {
        undoManager.canUndo
    }


    var canRedo: Bool {
        undoManager.canRedo
    }


    func save() -> [RegisteredConfigVariable] {
        let changedKeys = document.save()
        return changedKeys.compactMap { registeredVariables[$0] }
    }


    func clearAllOverrides() {
        document.removeAllOverrides()
    }


    func undo() {
        undoManager.undo()
    }


    func redo() {
        undoManager.redo()
    }


    func makeDetailViewModel(for key: ConfigKey) -> ConfigVariableDetailViewModel {
        guard let variable = registeredVariables[key] else {
            preconditionFailure("No registered variable for key '\(key)'")
        }

        return ConfigVariableDetailViewModel(
            variable: variable,
            document: document,
            namedProviders: namedProviders
        )
    }
}


// MARK: - Value Resolution

extension ConfigVariableListViewModel {
    /// Resolves the current value, owning provider name, and provider index for a registered variable.
    ///
    /// Checks the document's working copy first, then queries each provider in order. Falls back to the variable's
    /// default content if no provider has a value.
    private func resolvedValue(for variable: RegisteredConfigVariable) -> (ConfigContent, String, Int) {
        if let override = document.override(forKey: variable.key) {
            let editorIndex =
                namedProviders.firstIndex { $0.provider.providerName == EditorOverrideProvider.providerName } ?? 0
            return (override, namedProviders[editorIndex].displayName, editorIndex)
        }

        let absoluteKey = AbsoluteConfigKey(variable.key)
        let expectedType = variable.defaultContent.configType

        for (index, namedProvider) in namedProviders.enumerated() {
            if let result = try? namedProvider.provider.value(forKey: absoluteKey, type: expectedType),
                let value = result.value
            {
                return (value.content, namedProvider.displayName, index)
            }
        }

        return (
            variable.defaultContent,
            localizedString("editor.defaultProviderName"),
            namedProviders.count
        )
    }
}

#endif
