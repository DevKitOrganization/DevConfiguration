//
//  ConfigVariableListViewModel.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/9/2026.
//

#if os(iOS)

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

    /// An optional closure to call when the editor is dismissed.
    ///
    /// It receives the registered variables whose overrides changed, or an empty array if the user dismissed without
    /// saving.
    private let dismiss: (([RegisteredConfigVariable]) -> Void)?

    var searchText = ""
    var isShowingSaveAlert = false
    var isShowingClearAlert = false


    /// Creates a new list view model.
    ///
    /// - Parameters:
    ///   - document: The editor document.
    ///   - dismiss: An optional closure called when the editor is dismissed. It receives the registered variables whose
    ///     overrides changed, or an empty array if the user dismissed without saving. If `nil`, the view's environment
    ///     dismiss action is used instead.
    init(document: EditorDocument, dismiss: (([RegisteredConfigVariable]) -> Void)?) {
        self.document = document
        self.dismiss = dismiss
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
                editorControl: variable.editorControl,
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
            dismissWithoutSaving(dismiss)
        }
    }


    func saveAndDismiss(_ dismiss: () -> Void) {
        let changedKeys = document.changedKeys
        document.save()
        let changedVariables = changedKeys.compactMap { document.registeredVariables[$0] }

        if let dismiss = self.dismiss {
            dismiss(changedVariables)
        } else {
            dismiss()
        }
    }


    func dismissWithoutSaving(_ dismiss: () -> Void) {
        if let dismiss = self.dismiss {
            dismiss([])
        } else {
            dismiss()
        }
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
