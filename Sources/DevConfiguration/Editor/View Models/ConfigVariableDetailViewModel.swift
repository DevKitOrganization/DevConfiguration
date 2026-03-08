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

    /// The reader's providers, queried for per-provider values.
    private let providers: [any ConfigProvider]

    /// Whether the variable's secret value is currently revealed.
    var isSecretRevealed = false


    /// Creates a new detail view model.
    ///
    /// - Parameters:
    ///   - variable: The registered variable to display.
    ///   - document: The editor document managing the working copy.
    ///   - providers: The reader's providers.
    init(
        variable: RegisteredConfigVariable,
        document: EditorDocument,
        providers: [any ConfigProvider]
    ) {
        self.variable = variable
        self.document = document
        self.providers = providers
    }


    var key: ConfigKey {
        variable.key
    }


    var displayName: String {
        variable.displayName ?? variable.key.description
    }


    var metadataEntries: [ConfigVariableMetadata.DisplayText] {
        variable.metadata.displayTextEntries
    }


    var providerValues: [ProviderValue] {
        let absoluteKey = AbsoluteConfigKey(variable.key)
        let expectedType = variable.defaultContent.configType

        return providers.compactMap { provider in
            guard
                let result = try? provider.value(forKey: absoluteKey, type: expectedType),
                let configValue = result.value
            else {
                return nil
            }

            return ProviderValue(
                providerName: provider.providerName,
                valueString: configValue.content.displayString
            )
        }
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
            guard let content = document.override(forKey: variable.key) else {
                return ""
            }
            return content.displayString
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
