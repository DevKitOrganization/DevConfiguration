//
//  IsEditableMetadataKey.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/17/2026.
//

import Foundation

/// The metadata key indicating whether a variable is editable in the variable editor.
private struct IsEditableMetadataKey: ConfigVariableMetadataKey {
    static let defaultValue = true
    static let keyDisplayText = localizedString("isEditableMetadata.keyDisplayText")
}


extension ConfigVariableMetadata {
    /// Whether the configuration variable is editable in the variable editor.
    ///
    /// When `false`, the editor UI hides the override controls for this variable. Defaults to `true`.
    public var isEditable: Bool {
        get { self[IsEditableMetadataKey.self] }
        set { self[IsEditableMetadataKey.self] = newValue }
    }
}
