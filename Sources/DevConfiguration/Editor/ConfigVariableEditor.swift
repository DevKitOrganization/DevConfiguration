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


    /// Creates a new configuration variable editor.
    ///
    /// - Parameters:
    ///   - reader: The configuration variable reader. If the reader was not created with `isEditorEnabled` set to
    ///     `true`, the view is empty.
    ///   - onSave: A closure called with the registered variables whose overrides changed when the user saves.
    public init(
        reader: ConfigVariableReader,
        onSave: @escaping ([RegisteredConfigVariable]) -> Void
    ) {
        if let editorOverrideProvider = reader.editorOverrideProvider {
            // Exclude the editor override provider from the named providers passed to the document,
            // since it is always the first entry in the reader's provider list
            let namedProviders = Array(reader.namedProviders.dropFirst())

            let document = EditorDocument(
                editorOverrideProvider: editorOverrideProvider,
                workingCopyDisplayName: localizedString("editorOverrideProvider.name"),
                namedProviders: namedProviders,
                registeredVariables: Array(reader.registeredVariables.values),
                undoManager: UndoManager()
            )

            self._viewModel = State(
                initialValue: ConfigVariableListViewModel(document: document, onSave: onSave)
            )
        }
    }


    public var body: some View {
        if let viewModel {
            ConfigVariableListView(viewModel: viewModel)
        }
    }
}

#endif
