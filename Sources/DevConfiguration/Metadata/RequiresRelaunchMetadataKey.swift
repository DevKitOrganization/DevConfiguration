//
//  RequiresRelaunchMetadataKey.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/7/2026.
//

import Foundation

/// The metadata key indicating that changes to a variable require an app relaunch to take effect.
private struct RequiresRelaunchMetadataKey: ConfigVariableMetadataKey {
    static let defaultValue = false
    static let keyDisplayText = String(localized: "requiresRelaunchMetadata.keyDisplayText", bundle: #bundle)
}


extension ConfigVariableMetadata {
    /// Whether changes to the configuration variable require an app relaunch to take effect.
    ///
    /// When `true`, the editor UI communicates this to consumers via the `onSave` closure so they can prompt the user
    /// to relaunch the app. Defaults to `false`.
    public var requiresRelaunch: Bool {
        get { self[RequiresRelaunchMetadataKey.self] }
        set { self[RequiresRelaunchMetadataKey.self] = newValue }
    }
}
