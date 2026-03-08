//
//  ConfigVariableEditor.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/8/2026.
//

#if canImport(SwiftUI)

import SwiftUI

/// A SwiftUI view that presents the configuration variable editor.
///
/// `ConfigVariableEditor` is the public entry point for the editor UI. It is initialized with a
/// ``ConfigVariableReader`` that has editor support enabled and an `onSave` closure that receives the registered
/// variables whose overrides changed.
///
/// The consumer is responsible for presentation (sheet, full-screen cover, navigation push, etc.).
///
///     .sheet(isPresented: $isEditorPresented) {
///         ConfigVariableEditor(reader: reader) { changedVariables in
///             // Handle changed variables
///         } onCancel: {
///             isEditorPresented = false
///         }
///     }
public struct ConfigVariableEditor: View {
    /// The list view model created from the reader.
    @State private var viewModel: ConfigVariableListViewModel

    /// The closure to call with the changed variables when the user saves.
    private let onSave: ([RegisteredConfigVariable]) -> Void

    /// The closure to call when the user cancels editing.
    private let onCancel: () -> Void


    /// Creates a new configuration variable editor.
    ///
    /// - Parameters:
    ///   - reader: The configuration variable reader. Must have been created with `isEditorEnabled` set to `true`.
    ///   - onSave: A closure called with the registered variables whose overrides changed when the user saves.
    ///   - onCancel: A closure called when the user cancels editing.
    public init(
        reader: ConfigVariableReader,
        onSave: @escaping ([RegisteredConfigVariable]) -> Void,
        onCancel: @escaping () -> Void
    ) {
        guard let editorOverrideProvider = reader.editorOverrideProvider else {
            preconditionFailure(
                "ConfigVariableEditor requires a ConfigVariableReader with isEditorEnabled set to true"
            )
        }

        let undoManager = UndoManager()
        let document = EditorDocument(provider: editorOverrideProvider, undoManager: undoManager)
        self._viewModel = State(
            initialValue: ConfigVariableListViewModel(
                document: document,
                registeredVariables: reader.registeredVariables,
                providers: reader.providers,
                undoManager: undoManager
            )
        )
        self.onSave = onSave
        self.onCancel = onCancel
    }


    public var body: some View {
        ConfigVariableEditorView(viewModel: viewModel, onSave: onSave, onCancel: onCancel)
    }
}

#endif
