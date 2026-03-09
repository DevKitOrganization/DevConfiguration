//
//  RegisteredConfigVariable.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/5/2026.
//

import Configuration

/// A non-generic representation of a registered ``ConfigVariable``.
///
/// `RegisteredConfigVariable` stores the type-erased information from a ``ConfigVariable`` so that registered variables
/// can be stored in homogeneous collections. It captures the variable's key, its default value as a ``ConfigContent``,
/// its secrecy setting, and any attached metadata.
@dynamicMemberLookup
public struct RegisteredConfigVariable: Sendable {
    /// The configuration key used to look up this variable's value.
    public let key: ConfigKey

    /// The variable's default value represented as a ``ConfigContent``.
    public let defaultContent: ConfigContent

    /// Whether this variable's value should be treated as secret.
    public let isSecret: Bool

    /// The configuration variable's metadata.
    public let metadata: ConfigVariableMetadata

    /// The name of the variable's Swift value type (e.g., `"Int"`, `"CardSuit"`).
    ///
    /// This is captured at registration time via `String(describing: Value.self)` and may differ from the content type
    /// name when the variable uses a type that maps to a primitive content type (e.g., an `Int`-backed enum stored as
    /// ``ConfigContent/int(_:)``).
    public let destinationTypeName: String

    /// The editor control to use when editing this variable's value in the editor UI.
    public let editorControl: EditorControl

    /// Parses a raw string from the editor UI into a ``ConfigContent`` value.
    ///
    /// Returns `nil` if the string cannot be parsed. When this property itself is `nil`, the variable does not support
    /// editing.
    let parse: (@Sendable (_ input: String) -> ConfigContent?)?


    /// Provides dynamic member lookup access to metadata properties.
    ///
    /// This subscript enables dot-syntax access to metadata properties, mirroring the access pattern on
    /// ``ConfigVariable``.
    ///
    /// - Parameter keyPath: A keypath to a property on `ConfigVariableMetadata`.
    /// - Returns: The value of the metadata property.
    subscript<MetadataValue>(
        dynamicMember keyPath: KeyPath<ConfigVariableMetadata, MetadataValue>
    ) -> MetadataValue {
        metadata[keyPath: keyPath]
    }
}
