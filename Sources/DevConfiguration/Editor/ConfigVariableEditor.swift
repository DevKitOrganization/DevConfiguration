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
/// `ConfigVariableEditor` is initialized with a ``ConfigVariableReader`` that has editor support enabled and an
/// `onSave` closure that receives the registered variables whose overrides changed.
///
/// The consumer is responsible for presentation (sheet, full-screen cover, navigation push, etc.).
///
///     .sheet(isPresented: $isEditorPresented) {
///         ConfigVariableEditor(reader: reader) { changedVariables in
///             // Handle changed variables
///         }
///     }
public struct ConfigVariableEditor: View {
    /// The list view model created from the reader.
    @State private var viewModel: ConfigVariableListViewModel?

    /// The closure to call with the changed variables when the user saves.
    private let onSave: ([RegisteredConfigVariable]) -> Void


    /// Creates a new configuration variable editor.
    ///
    /// - Parameters:
    ///   - reader: The configuration variable reader. If the reader does was not created with `isEditorEnabled` set to
    ///     `true`, the view is empty.
    ///   - onSave: A closure called with the registered variables whose overrides changed when the user saves.
    public init(
        reader: ConfigVariableReader,
        onSave: @escaping ([RegisteredConfigVariable]) -> Void
    ) {
        self.onSave = onSave

        if let editorOverrideProvider = reader.editorOverrideProvider {
            let undoManager = UndoManager()
            let document = EditorDocument(provider: editorOverrideProvider, undoManager: undoManager)
            self._viewModel = State(
                initialValue: ConfigVariableListViewModel(
                    document: document,
                    registeredVariables: reader.registeredVariables,
                    namedProviders: reader.namedProviders,
                    undoManager: undoManager
                )
            )
        }
    }


    public var body: some View {
        if let viewModel {
            ConfigVariableListView(viewModel: viewModel, onSave: onSave)
        }
    }
}

#endif
