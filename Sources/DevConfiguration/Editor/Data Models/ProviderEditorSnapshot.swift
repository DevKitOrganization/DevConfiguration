//
//  ProviderEditorSnapshot.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/9/2026.
//

import Configuration

/// A uniform representation of a provider's state for the editor UI.
///
/// All providers — including the "Default" pseudo-provider built from registered variable defaults — are represented
/// as `ProviderEditorSnapshot` values. Each snapshot has a display name, an index (for color assignment), and a map
/// of configuration keys to their content values.
struct ProviderEditorSnapshot {
    /// The human-readable display name for this provider.
    let displayName: String

    /// The position of this provider in the provider list, used for color assignment.
    let index: Int

    /// The current values for registered configuration keys.
    var values: [ConfigKey: ConfigContent]
}
