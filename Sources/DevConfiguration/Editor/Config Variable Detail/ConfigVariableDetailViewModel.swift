//
//  ConfigVariableDetailViewModel.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/8/2026.
//

#if canImport(SwiftUI)

import Configuration
import Foundation

/// The concrete detail view model for a single configuration variable in the editor.
///
/// `ConfigVariableDetailViewModel` displays a variable's metadata, the value from each provider, and override
/// controls. It delegates override mutations to the ``EditorDocument`` and parses text input using the variable's
/// parse closure.
@MainActor @Observable
final class ConfigVariableDetailViewModel: ConfigVariableDetailViewModeling {
    /// The registered variable this detail view model represents.
    private let variable: RegisteredConfigVariable

    /// The editor document managing the working copy.
    private let document: EditorDocument

    /// The reader's named providers, queried for per-provider values.
    private let namedProviders: [NamedConfigProvider]

    /// Whether the variable's secret value is currently revealed.
    var isSecretRevealed = false


    var isSecret: Bool {
        variable.isSecret
    }


    /// Creates a new detail view model.
    ///
    /// - Parameters:
    ///   - variable: The registered variable to display.
    ///   - document: The editor document managing the working copy.
    ///   - namedProviders: The reader's named providers.
    init(
        variable: RegisteredConfigVariable,
        document: EditorDocument,
        namedProviders: [NamedConfigProvider]
    ) {
        self.variable = variable
        self.document = document
        self.namedProviders = namedProviders
    }


    var key: ConfigKey {
        variable.key
    }


    var displayName: String {
        variable.displayName ?? variable.key.description
    }


    var typeName: String {
        variable.defaultContent.typeDisplayName
    }


    var metadataEntries: [ConfigVariableMetadata.DisplayText] {
        variable.metadata.displayTextEntries
    }


    var providerValues: [ProviderValue] {
        let absoluteKey = AbsoluteConfigKey(variable.key)
        let expectedType = variable.defaultContent.configType
        let overrideContent = document.override(forKey: variable.key)
        let hasOverride = overrideContent != nil

        var values: [ProviderValue] = []

        // If there's a working copy override, show it as the editor provider value
        if let overrideContent {
            let editorIndex =
                namedProviders.firstIndex { $0.provider.providerName == EditorOverrideProvider.providerName } ?? 0

            values.append(
                ProviderValue(
                    providerName: namedProviders[editorIndex].displayName,
                    providerIndex: editorIndex,
                    isActive: true,
                    valueString: overrideContent.displayString
                )
            )
        }

        var foundActive = false
        for (index, namedProvider) in namedProviders.enumerated() {
            // Skip the editor provider since we handle it above from the working copy
            if namedProvider.provider.providerName == EditorOverrideProvider.providerName {
                continue
            }

            guard
                let result = try? namedProvider.provider.value(forKey: absoluteKey, type: expectedType),
                let configValue = result.value
            else {
                continue
            }

            let isActive = !hasOverride && !foundActive
            foundActive = foundActive || isActive

            values.append(
                ProviderValue(
                    providerName: namedProvider.displayName,
                    providerIndex: index,
                    isActive: isActive,
                    valueString: configValue.content.displayString
                )
            )
        }

        // Always show the default value last
        values.append(
            ProviderValue(
                providerName: localizedString("editor.defaultProviderName"),
                providerIndex: namedProviders.count,
                isActive: !hasOverride && !foundActive,
                valueString: variable.defaultContent.displayString
            )
        )

        return values
    }


    var isOverrideEnabled: Bool {
        get {
            document.hasOverride(forKey: variable.key)
        }
        set {
            if newValue {
                document.setOverride(variable.defaultContent, forKey: variable.key)
            } else {
                document.removeOverride(forKey: variable.key)
            }
        }
    }


    var overrideText: String {
        get {
            return document.override(forKey: variable.key)?.displayString ?? ""
        }
        set {
            guard let parse = variable.parse, let content = parse(newValue) else {
                return
            }
            document.setOverride(content, forKey: variable.key)
        }
    }


    var overrideBool: Bool {
        get {
            guard case .bool(let value) = document.override(forKey: variable.key) else {
                return false
            }
            return value
        }
        set {
            document.setOverride(.bool(newValue), forKey: variable.key)
        }
    }


    var editorControl: EditorControl {
        variable.editorControl
    }
}

#endif
