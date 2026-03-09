//
//  ConfigVariableListViewModel.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/9/2026.
//

#if canImport(SwiftUI)

import Configuration
import Foundation

/// The concrete view model for the configuration variable list view.
///
/// `ConfigVariableListViewModel` queries an ``EditorDocument`` to build the list of variable items, handles search
/// filtering and sorting, and delegates save, undo, and redo operations to the document.
@MainActor
@Observable
final class ConfigVariableListViewModel: ConfigVariableListViewModeling {
    /// The document that owns the variable data.
    private let document: EditorDocument

    /// The closure to call with the changed variables when the user saves.
    private let onSave: ([RegisteredConfigVariable]) -> Void

    var searchText = ""
    var isShowingSaveAlert = false
    var isShowingClearAlert = false


    /// Creates a new list view model.
    ///
    /// - Parameters:
    ///   - document: The editor document.
    ///   - onSave: A closure called with the registered variables whose overrides changed when the user saves.
    init(document: EditorDocument, onSave: @escaping ([RegisteredConfigVariable]) -> Void) {
        self.document = document
        self.onSave = onSave
    }


    // MARK: - Variables

    var variables: [VariableListItem] {
        let items = document.registeredVariables.values.map { variable -> VariableListItem in
            let displayName = variable.displayName ?? variable.key.description
            let resolved = document.resolvedValue(forKey: variable.key)

            return VariableListItem(
                key: variable.key,
                displayName: displayName,
                currentValue: resolved?.content.displayString ?? "",
                providerName: resolved?.providerDisplayName ?? "",
                providerIndex: resolved?.providerIndex,
                isSecret: variable.isSecret,
                hasOverride: document.hasOverride(forKey: variable.key),
                editorControl: variable.editorControl
            )
        }

        let filtered: [VariableListItem]
        if searchText.isEmpty {
            filtered = items
        } else {
            filtered = items.filter { item in
                item.displayName.localizedStandardContains(searchText)
                    || item.key.description.localizedStandardContains(searchText)
            }
        }

        return filtered.sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
    }


    // MARK: - Dirty Tracking

    var isDirty: Bool {
        document.isDirty
    }


    var canUndo: Bool {
        document.undoManager.canUndo
    }


    var canRedo: Bool {
        document.undoManager.canRedo
    }


    // MARK: - Actions

    func requestDismiss(_ dismiss: () -> Void) {
        if isDirty {
            isShowingSaveAlert = true
        } else {
            dismiss()
        }
    }


    func save() {
        let changedKeys = document.changedKeys
        document.save()
        onSave(changedKeys.compactMap { document.registeredVariables[$0] })
    }


    func requestClearAllOverrides() {
        isShowingClearAlert = true
    }


    func confirmClearAllOverrides() {
        document.removeAllOverrides()
    }


    func undo() {
        document.undoManager.undo()
    }


    func redo() {
        document.undoManager.redo()
    }


    // MARK: - Detail View Model

    func makeDetailViewModel(for key: ConfigKey) -> ConfigVariableDetailViewModel {
        let registeredVariable = document.registeredVariables[key]!
        return ConfigVariableDetailViewModel(document: document, registeredVariable: registeredVariable)
    }
}

#endif
