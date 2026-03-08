//
//  ConfigVariableEditorView.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/8/2026.
//

#if canImport(SwiftUI)

import Configuration
import SwiftUI

/// The list view for the configuration variable editor.
///
/// `ConfigVariableEditorView` displays all registered configuration variables in a searchable, sorted list. Each row
/// shows the variable's display name, key, current value, and a provider badge. Tapping a row navigates to the
/// variable's detail view.
///
/// The toolbar provides Cancel, Save, and an overflow menu with Undo, Redo, and Clear Editor Overrides actions.
struct ConfigVariableEditorView<ViewModel: ConfigVariableListViewModeling>: View {
    @State var viewModel: ViewModel

    /// The closure to call with the changed variables when the user saves.
    var onSave: ([RegisteredConfigVariable]) -> Void

    /// The closure to call when the user cancels editing.
    var onCancel: () -> Void

    @State private var isShowingDiscardAlert = false
    @State private var isShowingClearAlert = false


    var body: some View {
        NavigationStack {
            List(viewModel.variables, id: \.key) { item in
                NavigationLink(value: item.key) {
                    VariableRow(item: item)
                }
            }
            .navigationTitle(String(localized: "editorView.navigationTitle", bundle: #bundle))
            .navigationDestination(for: ConfigKey.self) { key in
                ConfigVariableDetailView(viewModel: viewModel.makeDetailViewModel(for: key))
            }
            .searchable(text: $viewModel.searchText)
            .toolbar { toolbarContent }
            .alert(
                String(localized: "editorView.discardAlert.title", bundle: #bundle),
                isPresented: $isShowingDiscardAlert
            ) {
                Button(
                    String(localized: "editorView.discardAlert.discardButton", bundle: #bundle),
                    role: .destructive
                ) {
                    viewModel.cancel()
                    onCancel()
                }

                Button(
                    String(localized: "editorView.discardAlert.keepEditingButton", bundle: #bundle),
                    role: .cancel
                ) {}
            } message: {
                Text(String(localized: "editorView.discardAlert.message", bundle: #bundle))
            }
            .alert(
                String(localized: "editorView.clearAlert.title", bundle: #bundle),
                isPresented: $isShowingClearAlert
            ) {
                Button(
                    String(localized: "editorView.clearAlert.clearButton", bundle: #bundle),
                    role: .destructive
                ) {
                    viewModel.clearAllOverrides()
                }

                Button(
                    String(localized: "editorView.discardAlert.keepEditingButton", bundle: #bundle),
                    role: .cancel
                ) {}
            } message: {
                Text(String(localized: "editorView.clearAlert.message", bundle: #bundle))
            }
        }
    }
}


// MARK: - Toolbar

extension ConfigVariableEditorView {
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                if viewModel.isDirty {
                    isShowingDiscardAlert = true
                } else {
                    viewModel.cancel()
                    onCancel()
                }
            } label: {
                Label(String(localized: "editorView.cancelButton", bundle: #bundle), systemImage: "xmark")
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button {
                let changedVariables = viewModel.save()
                onSave(changedVariables)
            } label: {
                Label(String(localized: "editorView.saveButton", bundle: #bundle), systemImage: "checkmark")
            }
        }

        ToolbarItem(placement: .primaryAction) {
            Menu {
                Button(String(localized: "editorView.undoButton", bundle: #bundle)) {
                    viewModel.undo()
                }
                .disabled(!viewModel.canUndo)

                Button(String(localized: "editorView.redoButton", bundle: #bundle)) {
                    viewModel.redo()
                }
                .disabled(!viewModel.canRedo)

                Divider()

                Button(String(localized: "editorView.clearOverridesButton", bundle: #bundle), role: .destructive) {
                    isShowingClearAlert = true
                }
            } label: {
                Label(
                    String(localized: "editorView.overflowMenu.label", bundle: #bundle),
                    systemImage: "ellipsis.circle"
                )
            }
        }
    }
}


// MARK: - Variable Row

extension ConfigVariableEditorView {
    /// A single row in the configuration variable list.
    private struct VariableRow: View {
        let item: VariableListItem


        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.displayName)
                    .font(.body)

                Text(item.key.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    Text(item.currentValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Spacer()

                    ProviderBadge(
                        providerName: item.providerName,
                        color: providerColor(at: item.providerIndex)
                    )
                }
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
    func cancel() {}
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
    ConfigVariableEditorView(
        viewModel: PreviewListViewModel(
            variables: [
                VariableListItem(
                    key: "feature.dark_mode",
                    displayName: "Dark Mode",
                    currentValue: "true",
                    providerName: "Editor",
                    providerIndex: 0,
                    hasOverride: true,
                    editorControl: .toggle
                ),
                VariableListItem(
                    key: "feature.api_endpoint",
                    displayName: "API Endpoint",
                    currentValue: "https://api.example.com",
                    providerName: "Remote",
                    providerIndex: 1,
                    hasOverride: false,
                    editorControl: .textField
                ),
                VariableListItem(
                    key: "feature.max_retries",
                    displayName: "Max Retries",
                    currentValue: "3",
                    providerName: "Default",
                    providerIndex: 2,
                    hasOverride: false,
                    editorControl: .numberField
                ),
                VariableListItem(
                    key: "feature.timeout",
                    displayName: "Timeout",
                    currentValue: "30.0",
                    providerName: "Remote",
                    providerIndex: 1,
                    hasOverride: false,
                    editorControl: .decimalField
                ),
            ],
            isDirty: true
        ),
        onSave: { _ in },
        onCancel: {}
    )
}

#endif
