//
//  ConfigVariableDetailView.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/8/2026.
//

#if canImport(SwiftUI)

import Configuration
import SwiftUI

/// The detail view for a single configuration variable in the editor.
///
/// `ConfigVariableDetailView` displays a variable's metadata, the value from each provider, and override controls.
/// It is generic on its view model protocol, allowing tests to inject mock view models.
struct ConfigVariableDetailView<ViewModel: ConfigVariableDetailViewModeling>: View {
    @State var viewModel: ViewModel
    @FocusState private var isTextEditorFocused: Bool


    var body: some View {
        Form {
            headerSection
            overrideSection
            providerValuesSection
            metadataSection
        }
        .navigationTitle(viewModel.displayName)
    }
}


// MARK: - Sections

extension ConfigVariableDetailView {
    private var headerSection: some View {
        Section {
            LabeledContent(localizedStringResource("detailView.headerSection.key")) {
                Text(viewModel.key.description)
                    .font(.caption.monospaced())
            }

            LabeledContent(localizedStringResource("detailView.headerSection.contentType")) {
                Text(viewModel.contentTypeName)
                    .font(.caption.monospaced())
            }

            LabeledContent(localizedStringResource("detailView.headerSection.variableType")) {
                Text(viewModel.variableTypeName)
                    .font(.caption.monospaced())
            }
        }
    }


    @ViewBuilder
    private var overrideSection: some View {
        if viewModel.editorControl != nil {
            Section(localizedStringResource("detailView.overrideSection.header")) {
                LabeledContent(localizedStringResource("detailView.overrideSection.editorOverrideLabel")) {
                    if viewModel.isOverrideEnabled {
                        Button(role: .destructive) {
                            viewModel.isOverrideEnabled = false
                        } label: {
                            HStack(alignment: .firstTextBaseline) {
                                Text(localized: "detailView.overrideSection.removeOverride")
                                Image(systemName: "xmark.circle.fill")
                            }
                        }
                        .tint(.red)
                    } else {
                        Button {
                            viewModel.isOverrideEnabled = true
                        } label: {
                            HStack(alignment: .firstTextBaseline) {
                                Text(localized: "detailView.overrideSection.addOverride")
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                    }
                }

                if viewModel.isOverrideEnabled {
                    overrideControl
                }
            }
        }
    }


    @ViewBuilder
    private var overrideControl: some View {
        if let editorControl = viewModel.editorControl {
            switch editorControl.kind {
            case .toggle:
                LabeledContent(localizedStringResource("detailView.overrideSection.valueLabel")) {
                    HStack {
                        Spacer().layoutPriority(0)
                        Picker(
                            localizedStringResource("detailView.overrideSection.valuePicker"),
                            selection: $viewModel.overrideBool
                        ) {
                            Text(localized: "detailView.overridenSection.valuePickerFalse").tag(false)
                            Text(localized: "detailView.overridenSection.valuePickerTrue").tag(true)
                        }
                        .pickerStyle(.segmented)
                    }
                }
            case .picker(options: let pickerOptions):
                Picker(
                    localizedStringResource("detailView.overrideSection.valuePicker"),
                    selection: $viewModel.overridePickerSelection
                ) {
                    ForEach(pickerOptions, id: \.content) { option in
                        Text(option.label).tag(option.content)
                    }
                }
            case .textEditor:
                VStack(alignment: .leading) {
                    Text(localizedStringResource("detailView.overrideSection.valueLabel"))
                    TextEditor(text: $viewModel.overrideText)
                        .focused($isTextEditorFocused)
                        .font(.caption.monospaced())
                        .frame(minHeight: 100)
                        .border(viewModel.isOverrideTextValid ? Color.clear : Color.red)
                        .autocorrectionDisabled()

                        #if os(iOS) || os(visionOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)
                        #endif

                    HStack {
                        Spacer()
                        Button(localizedStringResource("detailView.overrideSection.applyButton")) {
                            viewModel.commitOverrideText()
                            isTextEditorFocused = false
                        }
                        .buttonStyle(.bordered)
                        .disabled(!viewModel.isOverrideTextValid)
                    }
                }
            case .textField, .numberField, .decimalField:
                LabeledContent(localizedStringResource("detailView.overrideSection.valueLabel")) {
                    TextField(
                        localizedStringResource("detailView.overrideSection.valueTextField"),
                        text: $viewModel.overrideText
                    )
                    .onSubmit { viewModel.commitOverrideText() }
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.trailing)
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(viewModel.isOverrideTextValid ? Color.separator : Color.red)
                    )
                    #if os(iOS) || os(visionOS)
                    .keyboardType(keyboardType)
                    #endif
                }
            }
        }
    }


    #if os(iOS) || os(visionOS)
    private var keyboardType: UIKeyboardType {
        if viewModel.editorControl == .numberField {
            .numberPad
        } else if viewModel.editorControl == .decimalField {
            .decimalPad
        } else {
            .default
        }
    }
    #endif


    private var providerValuesSection: some View {
        Section(localizedStringResource("detailView.providerValuesSection.header")) {
            if viewModel.isSecret && !viewModel.isSecretRevealed {
                Button(localizedStringResource("detailView.providerValuesSection.tapToReveal")) {
                    viewModel.isSecretRevealed = true
                }
            } else {
                ForEach(viewModel.providerValues, id: \.self) { providerValue in
                    LabeledContent {
                        Text(providerValue.valueString)
                            .font(.caption.monospaced())
                            .strikethrough(!providerValue.contentTypeMatches)
                    } label: {
                        ProviderBadge(
                            providerName: providerValue.providerName,
                            color: providerColor(at: providerValue.providerIndex),
                            isActive: providerValue.isActive
                        )
                        .strikethrough(!providerValue.contentTypeMatches)
                    }
                }

                if viewModel.isSecret {
                    Button(localizedStringResource("detailView.providerValuesSection.hideValues")) {
                        viewModel.isSecretRevealed = false
                    }
                }
            }
        }
    }


    @ViewBuilder
    private var metadataSection: some View {
        let entries = viewModel.metadataEntries
        if !entries.isEmpty {
            Section(localizedStringResource("detailView.metadataSection.header")) {
                ForEach(entries, id: \.key) { entry in
                    LabeledContent(entry.key, value: entry.value ?? "—")
                }
            }
        }
    }
}

#endif


extension Color {
    static var separator: Color {
        #if canImport(UIKit)
        Color(UIColor.separator)
        #elseif canImport(AppKit)
        Color(NSColor.separatorColor)
        #endif
    }
}
