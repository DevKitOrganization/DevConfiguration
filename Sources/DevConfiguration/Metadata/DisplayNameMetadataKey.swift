//
//  DisplayNameMetadataKey.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/7/2026.
//

import Foundation

/// The metadata key for a human-readable display name.
private struct DisplayNameMetadataKey: ConfigVariableMetadataKey {
    static let defaultValue: String? = nil
    static let keyDisplayText = String(localized: "displayNameMetadata.keyDisplayText", bundle: #bundle)
}


extension ConfigVariableMetadata {
    /// A human-readable display name for the configuration variable.
    ///
    /// When set, this name is used in the editor UI and other display contexts instead of the raw configuration key.
    /// When `nil`, the variable's key is used as the display text.
    public var displayName: String? {
        get { self[DisplayNameMetadataKey.self] }
        set { self[DisplayNameMetadataKey.self] = newValue }
    }
}
