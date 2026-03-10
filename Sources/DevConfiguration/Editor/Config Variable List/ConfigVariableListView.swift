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
struct ConfigVariableListView<ViewModel: ConfigVariableListViewModeling, CustomSection: View>: View {
    @State var viewModel: ViewModel

    /// The title for the custom section at the top of the list.
    private let customSectionTitle: Text

    /// The custom section content to display at the top of the list.
    private let customSection: CustomSection

    @Environment(\.dismiss) private var dismiss


    /// Creates a new list view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model for the list.
    ///   - customSectionTitle: The title for the custom section.
    ///   - customSection: A view builder that produces custom content to display in a section at the top of the list.
    init(viewModel: ViewModel, customSectionTitle: Text, @ViewBuilder customSection: () -> CustomSection) {
        self._viewModel = State(initialValue: viewModel)
        self.customSectionTitle = customSectionTitle
        self.customSection = customSection()
    }


    var body: some View {
        NavigationStack {
            List {
                if CustomSection.self != EmptyView.self {
                    Section {
                        customSection
                    } header: {
                        customSectionTitle
                    }
                }

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
            .interactiveDismissDisabled(viewModel.isDirty)
            .searchable(text: $viewModel.searchText)
            .toolbar { toolbarContent }
            .alert(localizedStringResource("editorView.saveAlert.title"), isPresented: $viewModel.isShowingSaveAlert) {
                Button(localizedStringResource("editorView.saveAlert.saveButton")) {
                    viewModel.save()
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
            .alert(
                localizedStringResource("editorView.clearAlert.title"),
                isPresented: $viewModel.isShowingClearAlert
            ) {
                Button(localizedStringResource("editorView.clearAlert.clearButton"), role: .destructive) {
                    viewModel.confirmClearAllOverrides()
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
                viewModel.requestDismiss { dismiss() }
            } label: {
                Label(localizedStringResource("editorView.dismissButton"), systemImage: "xmark")
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button {
                viewModel.save()
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
                    viewModel.requestClearAllOverrides()
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

#endif
