//
//  ConfigVariableEditor.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/8/2026.
//

#if os(iOS)

import SwiftUI

/// A SwiftUI view that presents the configuration variable editor.
///
/// `ConfigVariableEditor` is initialized with a ``ConfigVariableReader`` that has editor support enabled and an
/// optional `dismiss` closure that receives the registered variables whose overrides changed.
///
/// The consumer is responsible for presentation (sheet, full-screen cover, navigation push, etc.). If no `dismiss`
/// closure is provided, the editor uses the environment's dismiss action.
///
///     .sheet(isPresented: $isEditorPresented) {
///         ConfigVariableEditor(reader: reader) { changedVariables in
///             // Handle changed variables and dismiss
///         }
///     }
///
/// To add a custom section at the top of the list, provide a section title and content:
///
///     ConfigVariableEditor(
///         reader: reader,
///         customSectionTitle: "Actions"
///     ) {
///         Button("Reset All") { … }
///     } dismiss: { changedVariables in
///         // Handle changed variables and dismiss
///     }
public struct ConfigVariableEditor<CustomSection: View>: View {
    /// The list view model created from the reader.
    @State private var viewModel: ConfigVariableListViewModel?

    /// The title for the custom section.
    private let customSectionTitle: Text

    /// The custom section content.
    private let customSection: CustomSection


    /// Creates a new configuration variable editor with a custom section at the top of the list.
    ///
    /// - Parameters:
    ///   - reader: The configuration variable reader. If the reader was not created with `isEditorEnabled` set to
    ///     `true`, the view is empty.
    ///   - customSectionTitle: The title for the custom section.
    ///   - customSection: A view builder that produces custom content to display in a section at the top of the list.
    ///   - dismiss: An optional closure called when the editor is dismissed. It receives the registered variables whose
    ///     overrides changed, or an empty array if dismissed without saving. If `nil`, the environment's dismiss action
    ///     is used.
    public init(
        reader: ConfigVariableReader,
        customSectionTitle: LocalizedStringKey,
        @ViewBuilder customSection: () -> CustomSection,
        dismiss: (([RegisteredConfigVariable]) -> Void)? = nil,
    ) {
        self.init(
            reader: reader,
            customSectionTitle: Text(customSectionTitle),
            customSection: customSection,
            dismiss: dismiss,
        )
    }


    /// Creates a new configuration variable editor with a custom section at the top of the list.
    ///
    /// - Parameters:
    ///   - reader: The configuration variable reader. If the reader was not created with `isEditorEnabled` set to
    ///     `true`, the view is empty.
    ///   - customSectionTitle: A `Text` view to use as the title for the custom section.
    ///   - customSection: A view builder that produces custom content to display in a section at the top of the list.
    ///   - dismiss: An optional closure called when the editor is dismissed. It receives the registered variables whose
    ///     overrides changed, or an empty array if dismissed without saving. If `nil`, the environment's dismiss action
    ///     is used.
    public init(
        reader: ConfigVariableReader,
        customSectionTitle: Text,
        @ViewBuilder customSection: () -> CustomSection,
        dismiss: (([RegisteredConfigVariable]) -> Void)? = nil,
    ) {
        self.customSectionTitle = customSectionTitle
        self.customSection = customSection()
        self._viewModel = Self.makeViewModel(reader: reader, dismiss: dismiss)
    }


    public var body: some View {
        if let viewModel {
            ConfigVariableListView(
                viewModel: viewModel,
                customSectionTitle: customSectionTitle,
                customSection: { customSection },
            )
        }
    }


    private static func makeViewModel(
        reader: ConfigVariableReader,
        dismiss: (([RegisteredConfigVariable]) -> Void)?,
    ) -> State<ConfigVariableListViewModel?> {
        guard let editorOverrideProvider = reader.editorOverrideProvider else {
            return State(initialValue: nil)
        }

        // Exclude the editor override provider from the named providers passed to the document,
        // since it is always the first entry in the reader's provider list
        let namedProviders = Array(reader.namedProviders.dropFirst())

        let document = EditorDocument(
            editorOverrideProvider: editorOverrideProvider,
            workingCopyDisplayName: localizedString("editorOverrideProvider.name"),
            namedProviders: namedProviders,
            registeredVariables: Array(reader.registeredVariables.values),
            undoManager: UndoManager(),
        )

        return State(initialValue: ConfigVariableListViewModel(document: document, dismiss: dismiss))
    }
}


extension ConfigVariableEditor where CustomSection == EmptyView {
    /// Creates a new configuration variable editor.
    ///
    /// - Parameters:
    ///   - reader: The configuration variable reader. If the reader was not created with `isEditorEnabled` set to
    ///     `true`, the view is empty.
    ///   - dismiss: An optional closure called when the editor is dismissed. It receives the registered variables whose
    ///     overrides changed, or an empty array if dismissed without saving. If `nil`, the environment's dismiss action
    ///     is used.
    public init(
        reader: ConfigVariableReader,
        dismiss: (([RegisteredConfigVariable]) -> Void)? = nil,
    ) {
        self.customSectionTitle = Text(verbatim: "")
        self.customSection = EmptyView()
        self._viewModel = Self.makeViewModel(reader: reader, dismiss: dismiss)
    }
}

#endif
