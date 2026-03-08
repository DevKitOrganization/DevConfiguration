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
            Text(viewModel.key.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }


    @ViewBuilder
    private var overrideSection: some View {
        if viewModel.editorControl != .none {
            Section(String(localized: "detailView.overrideSection.header", bundle: #bundle)) {
                Toggle(
                    String(localized: "detailView.overrideSection.enableToggle", bundle: #bundle),
                    isOn: $viewModel.isOverrideEnabled
                )

                if viewModel.isOverrideEnabled {
                    overrideControl
                }
            }
        }
    }


    @ViewBuilder
    private var overrideControl: some View {
        if viewModel.editorControl == .toggle {
            Toggle(
                String(localized: "detailView.overrideSection.valueToggle", bundle: #bundle),
                isOn: $viewModel.overrideBool
            )
        } else {
            TextField(
                String(localized: "detailView.overrideSection.valueTextField", bundle: #bundle),
                text: $viewModel.overrideText
            )
            #if os(iOS) || os(visionOS)
            .keyboardType(keyboardType)
            #endif
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
        Section(String(localized: "detailView.providerValuesSection.header", bundle: #bundle)) {
            if viewModel.isSecret && !viewModel.isSecretRevealed {
                Button(String(localized: "detailView.providerValuesSection.tapToReveal", bundle: #bundle)) {
                    viewModel.isSecretRevealed = true
                }
            } else {
                ForEach(viewModel.providerValues, id: \.self) { providerValue in
                    LabeledContent {
                        ProviderBadge(
                            providerName: providerValue.providerName,
                            color: providerColor(at: providerValue.providerIndex)
                        )
                    } label: {
                        Text(providerValue.valueString)
                    }
                }
            }
        }
    }


    @ViewBuilder
    private var metadataSection: some View {
        let entries = viewModel.metadataEntries
        if !entries.isEmpty {
            Section(String(localized: "detailView.metadataSection.header", bundle: #bundle)) {
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
                    ProviderValue(providerName: "Remote", providerIndex: 1, valueString: "https://api.example.com"),
                    ProviderValue(providerName: "Default", providerIndex: 2, valueString: "https://localhost:8080"),
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
                providerValues: [
                    ProviderValue(providerName: "Remote", providerIndex: 1, valueString: "false")
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
                    ProviderValue(providerName: "Remote", providerIndex: 1, valueString: "sk-1234567890abcdef")
                ],
                isSecret: true,
                editorControl: .textField
            )
        )
    }
}

#endif
