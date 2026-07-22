//
//  ConfigVariableListView.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/8/2026.
//

#if os(iOS)

import Configuration
import SwiftUI

/// The list view for the configuration variable editor.
///
/// `ConfigVariableListView` displays all registered configuration variables in a searchable, sorted list. Each row
/// shows the variable's display name, key, current value, and a provider badge. Tapping a row navigates to the
/// variable's detail view.
///
/// The toolbar provides Cancel, Save, and an overflow menu with Undo, Redo, and Clear Editor Overrides actions.
struct ConfigVariableListView<ViewModel: ConfigVariableListViewModeling, CustomContent: View>: View {
    @State var viewModel: ViewModel

    /// The custom content to display at the top of the list.
    private let customContent: CustomContent

    @Environment(\.dismiss) private var dismiss


    /// Creates a new list view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model for the list.
    ///   - customContent: A view builder that produces custom content to display in a section at the top of the list.
    init(viewModel: ViewModel, @ViewBuilder customContent: () -> CustomContent) {
        self._viewModel = State(initialValue: viewModel)
        self.customContent = customContent()
    }


    var body: some View {
        NavigationStack {
            List {
                customContent

                variablesSection
            }
            .navigationTitle(localizedStringResource("editorView.navigationTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ConfigKey.self) { key in
                ConfigVariableDetailView(viewModel: viewModel.makeDetailViewModel(for: key))
            }
            .interactiveDismissDisabled(viewModel.isDirty)
            .searchable(text: $viewModel.searchText)
            .toolbar { toolbarContent }
            .alert(localizedStringResource("editorView.saveAlert.title"), isPresented: $viewModel.isShowingSaveAlert) {
                Button(localizedStringResource("editorView.saveAlert.saveButton")) {
                    viewModel.saveAndDismiss { dismiss() }
                }
                .keyboardShortcut(.defaultAction)

                Button(localizedStringResource("editorView.saveAlert.dontSaveButton"), role: .destructive) {
                    viewModel.dismissWithoutSaving { dismiss() }
                }

                Button(localizedStringResource("editorView.saveAlert.cancelButton"), role: .cancel) {}
            } message: {
                Text(localizedStringResource("editorView.saveAlert.message"))
            }
            .alert(
                localizedStringResource("editorView.clearAlert.title"),
                isPresented: $viewModel.isShowingClearAlert,
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


    @ViewBuilder
    var variablesSection: some View {
        if viewModel.showOverridesOnly {
            Section(localizedStringResource("editorView.overridesSection.header")) {
                ForEach(viewModel.variables, id: \.key) { item in
                    NavigationLink(value: item.key) {
                        VariableRow(item: item)
                    }
                }
            }
        } else {
            ForEach(viewModel.groupedVariables.groupedVariables, id: \.group) { section in
                Section(section.group.rawValue) {
                    ForEach(section.items, id: \.key) { item in
                        NavigationLink(value: item.key) {
                            VariableRow(item: item)
                        }
                    }
                }
            }

            if !viewModel.groupedVariables.remainder.isEmpty {
                Section(
                    viewModel.groupedVariables.groupedVariables.isEmpty
                        ? localizedStringResource("editorView.variablesSection.header")
                        : localizedStringResource("editorView.remainderSection.header")
                ) {
                    ForEach(viewModel.groupedVariables.remainder, id: \.key) { item in
                        NavigationLink(value: item.key) {
                            VariableRow(item: item)
                        }
                    }
                }
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
                viewModel.saveAndDismiss { dismiss() }
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

                Button {
                    viewModel.showOverridesOnly.toggle()
                } label: {
                    Label(
                        localizedStringResource("editorView.showOverridesOnlyButton"),
                        systemImage: viewModel.showOverridesOnly ? "checkmark.circle.fill" : "circle",
                    )
                }
                .disabled(!viewModel.hasAnyOverrides)

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
            VStack(alignment: .leading, spacing: 4) {
                Text(item.displayName)
                    .font(.subheadline)
                    .bold()

                Text(item.key.description)
                    .font(.caption.monospaced())

                HStack(alignment: .firstTextBaseline) {
                    ProviderBadge(
                        providerName: item.providerName,
                        color: providerColor(at: item.providerIndex),
                    )
                    Spacer()
                    Text(item.isSecret ? "••••••••" : item.currentValue)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .padding(.top, 6)
            }
        }
    }
}

#endif
