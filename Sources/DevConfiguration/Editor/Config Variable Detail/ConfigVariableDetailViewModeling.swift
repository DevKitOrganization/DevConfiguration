//
//  ConfigVariableDetailViewModeling.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/8/2026.
//

import Configuration
import Foundation

/// The view model protocol for the configuration variable detail view.
///
/// `ConfigVariableDetailViewModeling` defines the interface that the detail view uses to display a single
/// configuration variable's metadata, provider values, and override controls. It supports enabling and editing
/// overrides via the appropriate editor control, and toggling secret value visibility.
@MainActor
protocol ConfigVariableDetailViewModeling: Observable {
    /// The configuration key for this variable.
    var key: ConfigKey { get }

    /// The human-readable display name for this variable.
    var displayName: String { get }

    /// A human-readable name for this variable's value type, such as `"String"` or `"Int"`.
    var typeName: String { get }

    /// The metadata entries to display.
    var metadataEntries: [ConfigVariableMetadata.DisplayText] { get }

    /// The value from each provider for this variable.
    var providerValues: [ProviderValue] { get }

    /// Whether an editor override is enabled for this variable.
    ///
    /// Setting this to `true` enables the override with the variable's default value. Setting it to `false` removes
    /// the override.
    var isOverrideEnabled: Bool { get set }

    /// The override value as a string, for text-based editor controls.
    ///
    /// Setting this parses the string into a ``ConfigContent`` value using the variable's parse closure and updates
    /// the working copy if parsing succeeds.
    var overrideText: String { get set }

    /// The override value as a boolean, for toggle editor controls.
    var overrideBool: Bool { get set }

    /// The editor control to use when editing this variable's value.
    var editorControl: EditorControl { get }

    /// Whether this variable's value is secret.
    var isSecret: Bool { get }

    /// Whether the variable's secret value is currently revealed.
    var isSecretRevealed: Bool { get set }
}
