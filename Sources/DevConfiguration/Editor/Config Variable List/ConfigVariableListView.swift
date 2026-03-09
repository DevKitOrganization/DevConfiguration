//
//  ConfigVariableListView.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/8/2026.
//

#if canImport(SwiftUI)

import Configuration
import SwiftUI

/// The list view for the configuration variable editor.
///
/// `ConfigVariableListView` displays all registered configuration variables in a searchable, sorted list. Each row
/// shows the variable's display name, key, current value, and a provider badge. Tapping a row navigates to the
/// variable's detail view.
///
/// The toolbar provides Cancel, Save, and an overflow menu with Undo, Redo, and Clear Editor Overrides actions.
struct ConfigVariableListView<ViewModel: ConfigVariableListViewModeling>: View {
    @State var viewModel: ViewModel

    /// The closure to call with the changed variables when the user saves.
    var onSave: ([RegisteredConfigVariable]) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var isShowingSaveAlert = false
    @State private var isShowingClearAlert = false


    var body: some View {
        NavigationStack {
            List {
                Section(localizedStringResource("editorView.variablesSection.header")) {
                    ForEach(viewModel.variables, id: \.key) { item in
                        NavigationLink(value: item.key) {
                            VariableRow(item: item)
                        }
                    }
                }
            }
            .navigationTitle(localizedStringResource("editorView.navigationTitle"))
            #if os(iOS) || os(watchOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationDestination(for: ConfigKey.self) { key in
                ConfigVariableDetailView(viewModel: viewModel.makeDetailViewModel(for: key))
            }
            .searchable(text: $viewModel.searchText)
            .toolbar { toolbarContent }
            .alert(localizedStringResource("editorView.saveAlert.title"), isPresented: $isShowingSaveAlert) {
                Button(localizedStringResource("editorView.saveAlert.saveButton")) {
                    let changedVariables = viewModel.save()
                    onSave(changedVariables)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)

                Button(localizedStringResource("editorView.saveAlert.dontSaveButton"), role: .destructive) {
                    dismiss()
                }

                Button(localizedStringResource("editorView.saveAlert.cancelButton"), role: .cancel) {}
            } message: {
                Text(localizedStringResource("editorView.saveAlert.message"))
            }
            .alert(localizedStringResource("editorView.clearAlert.title"), isPresented: $isShowingClearAlert) {
                Button(localizedStringResource("editorView.clearAlert.clearButton"), role: .destructive) {
                    viewModel.clearAllOverrides()
                }

                Button(localizedStringResource("editorView.saveAlert.cancelButton"), role: .cancel) {}
            } message: {
                Text(localizedStringResource("editorView.clearAlert.message"))
            }
        }
    }
}


// MARK: - Toolbar

extension ConfigVariableListView {
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                if viewModel.isDirty {
                    isShowingSaveAlert = true
                } else {
                    dismiss()
                }
            } label: {
                Label(localizedStringResource("editorView.dismissButton"), systemImage: "xmark")
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button {
                let changedVariables = viewModel.save()
                onSave(changedVariables)
                dismiss()
            } label: {
                Label(localizedStringResource("editorView.saveButton"), systemImage: "checkmark")
            }
            .disabled(!viewModel.isDirty)
        }

        ToolbarItem(placement: .primaryAction) {
            Menu {
                Button {
                    viewModel.undo()
                } label: {
                    Label(localizedStringResource("editorView.undoButton"), systemImage: "arrow.uturn.backward")
                }
                .disabled(!viewModel.canUndo)

                Button {
                    viewModel.redo()
                } label: {
                    Label(localizedStringResource("editorView.redoButton"), systemImage: "arrow.uturn.forward")
                }
                .disabled(!viewModel.canRedo)

                Divider()

                Button(role: .destructive) {
                    isShowingClearAlert = true
                } label: {
                    Label(localizedStringResource("editorView.clearOverridesButton"), systemImage: "trash")
                }
            } label: {
                Label(localizedStringResource("editorView.overflowMenu.label"), systemImage: "ellipsis")
            }
        }
    }
}


// MARK: - Variable Row

extension ConfigVariableListView {
    /// A single row in the configuration variable list.
    private struct VariableRow: View {
        let item: VariableListItem


        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.displayName)
                    .font(.headline)

                Text(item.key.description)
                    .font(.caption.monospaced())

                HStack(alignment: .firstTextBaseline) {
                    ProviderBadge(
                        providerName: item.providerName,
                        color: providerColor(at: item.providerIndex)
                    )
                    Spacer()
                    Text(item.isSecret ? "••••••••" : item.currentValue)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .padding(.top, 8)
            }
            .padding(.vertical, 2)
        }
    }
}


// MARK: - Preview Support

@MainActor @Observable
private final class PreviewListViewModel: ConfigVariableListViewModeling {
    var variables: [VariableListItem]
    var searchText = ""
    var isDirty: Bool
    var canUndo = false
    var canRedo = false


    init(variables: [VariableListItem], isDirty: Bool = false) {
        self.variables = variables
        self.isDirty = isDirty
    }


    func save() -> [RegisteredConfigVariable] { [] }
    func clearAllOverrides() {}
    func undo() {}
    func redo() {}


    func makeDetailViewModel(for key: ConfigKey) -> PreviewEditorDetailViewModel {
        PreviewEditorDetailViewModel(key: key, displayName: key.description)
    }
}


@MainActor @Observable
private final class PreviewEditorDetailViewModel: ConfigVariableDetailViewModeling {
    let key: ConfigKey
    let displayName: String
    let typeName = "String"
    let metadataEntries: [ConfigVariableMetadata.DisplayText] = []
    let providerValues: [ProviderValue] = []
    let isSecret = false
    let editorControl: EditorControl = .none

    var isOverrideEnabled = false
    var overrideText = ""
    var overrideBool = false
    var isSecretRevealed = false


    init(key: ConfigKey, displayName: String) {
        self.key = key
        self.displayName = displayName
    }
}


#Preview {
    ConfigVariableListView(
        viewModel: PreviewListViewModel(
            variables: [
                VariableListItem(
                    key: "feature.dark_mode",
                    displayName: "Dark Mode",
                    currentValue: "true",
                    providerName: "Editor",
                    providerIndex: 0,
                    isSecret: false,
                    hasOverride: true,
                    editorControl: .toggle
                ),
                VariableListItem(
                    key: "feature.api_endpoint",
                    displayName: "API Endpoint",
                    currentValue: "https://api.example.com",
                    providerName: "Remote",
                    providerIndex: 1,
                    isSecret: false,
                    hasOverride: false,
                    editorControl: .textField
                ),
                VariableListItem(
                    key: "feature.max_retries",
                    displayName: "Max Retries",
                    currentValue: "3",
                    providerName: "Default",
                    providerIndex: 2,
                    isSecret: false,
                    hasOverride: false,
                    editorControl: .numberField
                ),
                VariableListItem(
                    key: "feature.timeout",
                    displayName: "Timeout",
                    currentValue: "30.0",
                    providerName: "Remote",
                    providerIndex: 1,
                    isSecret: false,
                    hasOverride: false,
                    editorControl: .decimalField
                ),
            ],
            isDirty: true
        ),
        onSave: { _ in }
    )
}

#endif
