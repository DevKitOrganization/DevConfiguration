//
//  VariableListItem.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/8/2026.
//

import Configuration

/// A data structure representing a single row in the configuration variable list.
///
/// Each `VariableListItem` contains the information needed to display a configuration variable in the editor's list
/// view, including its display name, current value, the provider that owns the value, and whether an editor override
/// is active.
struct VariableListItem: Hashable, Sendable {
    /// The configuration key for this variable.
    let key: ConfigKey

    /// The human-readable display name for this variable.
    ///
    /// This is the variable's ``ConfigVariableMetadata/displayName`` if set, or the key's description otherwise.
    let displayName: String

    /// The current resolved value formatted as a display string.
    let currentValue: String

    /// The name of the provider that currently owns this variable's value.
    let providerName: String

    /// The index of the provider in the reader's provider list, used for color assignment.
    let providerIndex: Int

    /// Whether an editor override is active for this variable in the working copy.
    let hasOverride: Bool

    /// The editor control to use when editing this variable's value.
    let editorControl: EditorControl
}
