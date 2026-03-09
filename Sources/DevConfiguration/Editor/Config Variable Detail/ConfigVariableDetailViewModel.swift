//
//  ConfigVariableDetailViewModel.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/9/2026.
//

#if canImport(SwiftUI)

import Configuration
import Foundation

/// The concrete view model for the configuration variable detail view.
///
/// `ConfigVariableDetailViewModel` queries an ``EditorDocument`` for a single registered variable's data and manages
/// override editing state. It is the single source of truth for the detail view's display and interaction logic.
@MainActor
@Observable
final class ConfigVariableDetailViewModel: ConfigVariableDetailViewModeling {
    /// The document that owns the variable data.
    private let document: EditorDocument

    /// The registered variable this view model represents.
    private let registeredVariable: RegisteredConfigVariable

    let key: ConfigKey
    let displayName: String
    let contentTypeName: String
    let variableTypeName: String
    let metadataEntries: [ConfigVariableMetadata.DisplayText]
    let isSecret: Bool
    let editorControl: EditorControl

    var overrideText = ""
    var isSecretRevealed = false


    /// Creates a new detail view model.
    ///
    /// - Parameters:
    ///   - document: The editor document.
    ///   - registeredVariable: The registered variable to display.
    init(document: EditorDocument, registeredVariable: RegisteredConfigVariable) {
        self.document = document
        self.registeredVariable = registeredVariable
        self.key = registeredVariable.key
        self.displayName = registeredVariable.displayName ?? registeredVariable.key.description
        self.contentTypeName = registeredVariable.contentTypeName
        self.variableTypeName = registeredVariable.destinationTypeName
        self.metadataEntries = registeredVariable.metadata.displayTextEntries
        self.isSecret = registeredVariable.isSecret
        self.editorControl = registeredVariable.editorControl

        if let content = document.override(forKey: registeredVariable.key) {
            self.overrideText = content.displayString
        } else if let resolved = document.resolvedValue(forKey: registeredVariable.key) {
            self.overrideText = resolved.content.displayString
        }
    }


    // MARK: - Provider Values

    var providerValues: [ProviderValue] {
        document.providerValues(forKey: key)
    }


    // MARK: - Override Management

    var isOverrideEnabled: Bool {
        get {
            document.hasOverride(forKey: key)
        }
        set {
            if newValue {
                enableOverride()
            } else {
                document.removeOverride(forKey: key)
            }
        }
    }


    var overrideBool: Bool {
        get {
            guard case .bool(let value) = document.override(forKey: key) else {
                return false
            }
            return value
        }
        set {
            document.setOverride(.bool(newValue), forKey: key)
        }
    }


    func commitOverrideText() {
        guard let parse = registeredVariable.parse else {
            return
        }

        let text = overrideText
        guard let content = parse(text) else {
            return
        }

        document.setOverride(content, forKey: key)
    }


    // MARK: - Private

    /// Enables an override by setting the default content or the current resolved value.
    private func enableOverride() {
        let content: ConfigContent
        if let resolved = document.resolvedValue(forKey: key) {
            content = resolved.content
        } else {
            content = registeredVariable.defaultContent
        }

        overrideText = content.displayString
        document.setOverride(content, forKey: key)
    }
}

#endif
