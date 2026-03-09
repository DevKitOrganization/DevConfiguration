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

            LabeledContent(localizedStringResource("detailView.headerSection.type")) {
                Text(viewModel.typeName)
                    .font(.caption.monospaced())
            }
        }
    }


    @ViewBuilder
    private var overrideSection: some View {
        if viewModel.editorControl != .none {
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
        LabeledContent(localizedStringResource("detailView.overrideSection.valueLabel")) {
            if viewModel.editorControl == .toggle {
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
            } else {
                TextField(
                    localizedStringResource("detailView.overrideSection.valueTextField"),
                    text: $viewModel.overrideText
                )
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                #if os(iOS) || os(visionOS)
                .keyboardType(keyboardType)
                #endif
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
                    } label: {
                        ProviderBadge(
                            providerName: providerValue.providerName,
                            color: providerColor(at: providerValue.providerIndex),
                            isActive: providerValue.isActive
                        )
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


// MARK: - Preview Support

@MainActor @Observable
private final class PreviewDetailViewModel: ConfigVariableDetailViewModeling {
    let key: ConfigKey
    let displayName: String
    let typeName: String
    let metadataEntries: [ConfigVariableMetadata.DisplayText]
    let providerValues: [ProviderValue]
    let isSecret: Bool
    let editorControl: EditorControl

    var isOverrideEnabled = false
    var overrideText = ""
    var overrideBool = false
    var isSecretRevealed = false


    init(
        key: ConfigKey,
        displayName: String,
        typeName: String = "String",
        metadataEntries: [ConfigVariableMetadata.DisplayText] = [],
        providerValues: [ProviderValue] = [],
        isSecret: Bool = false,
        editorControl: EditorControl = .textField,
        isOverrideEnabled: Bool = false,
        overrideText: String = "",
        overrideBool: Bool = false
    ) {
        self.key = key
        self.displayName = displayName
        self.typeName = typeName
        self.metadataEntries = metadataEntries
        self.providerValues = providerValues
        self.isSecret = isSecret
        self.editorControl = editorControl
        self.isOverrideEnabled = isOverrideEnabled
        self.overrideText = overrideText
        self.overrideBool = overrideBool
    }
}


#Preview("Text Field") {
    NavigationStack {
        ConfigVariableDetailView(
            viewModel: PreviewDetailViewModel(
                key: "feature.api_endpoint",
                displayName: "API Endpoint",
                metadataEntries: [
                    .init(key: "Display Name", value: "API Endpoint"),
                    .init(key: "Requires Relaunch", value: "Yes"),
                ],
                providerValues: [
                    ProviderValue(
                        providerName: "Remote", providerIndex: 1, isActive: false,
                        valueString: "https://api.example.com"),
                    ProviderValue(
                        providerName: "Default", providerIndex: 2, isActive: false,
                        valueString: "https://localhost:8080"),
                ],
                editorControl: .textField,
                isOverrideEnabled: true,
                overrideText: "https://staging.example.com"
            )
        )
    }
}


#Preview("Toggle") {
    NavigationStack {
        ConfigVariableDetailView(
            viewModel: PreviewDetailViewModel(
                key: "feature.dark_mode",
                displayName: "Dark Mode",
                typeName: "Bool",
                providerValues: [
                    ProviderValue(providerName: "Remote", providerIndex: 1, isActive: false, valueString: "false")
                ],
                editorControl: .toggle,
                isOverrideEnabled: true,
                overrideBool: true
            )
        )
    }
}


#Preview("Secret") {
    NavigationStack {
        ConfigVariableDetailView(
            viewModel: PreviewDetailViewModel(
                key: "service.api_key",
                displayName: "API Key",
                providerValues: [
                    ProviderValue(
                        providerName: "Remote", providerIndex: 1, isActive: true, valueString: "sk-1234567890abcdef")
                ],
                isSecret: true,
                editorControl: .textField
            )
        )
    }
}

#endif
