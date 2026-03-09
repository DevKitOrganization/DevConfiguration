//
//  ConfigVariableDetailViewModeling.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/9/2026.
//

#if canImport(SwiftUI)

import Configuration
import Foundation

/// The interface for a configuration variable detail view's view model.
///
/// `ConfigVariableDetailViewModeling` defines the minimal interface that ``ConfigVariableDetailView`` needs to display
/// and edit a single configuration variable. The view binds to properties and calls methods on this protocol without
/// knowing the concrete implementation.
@MainActor
protocol ConfigVariableDetailViewModeling: Observable {
    /// The configuration key for this variable.
    var key: ConfigKey { get }

    /// The human-readable display name for this variable.
    var displayName: String { get }

    /// The content type name to display in the header (e.g., `"Bool"` or `"[Int]"`).
    var contentTypeName: String { get }

    /// The variable type name to display in the header (e.g., `"Int"` or `"CardSuit"`).
    var variableTypeName: String { get }

    /// The metadata entries to display in the metadata section.
    var metadataEntries: [ConfigVariableMetadata.DisplayText] { get }

    /// The provider values to display in the provider values section.
    var providerValues: [ProviderValue] { get }

    /// Whether this variable's value is secret.
    var isSecret: Bool { get }

    /// The editor control to use for this variable's override.
    var editorControl: EditorControl { get }

    /// Whether the user has enabled an override for this variable.
    var isOverrideEnabled: Bool { get set }

    /// The text value for the override, used with text field and number field controls.
    var overrideText: String { get set }

    /// The boolean value for the override, used with toggle controls.
    var overrideBool: Bool { get set }

    /// Whether the secret value is currently revealed.
    var isSecretRevealed: Bool { get set }

    /// Commits the current override text to the document.
    ///
    /// Called when the user submits the text field. Parses the text into a ``ConfigContent`` and sets the override
    /// on the document.
    func commitOverrideText()
}

#endif
