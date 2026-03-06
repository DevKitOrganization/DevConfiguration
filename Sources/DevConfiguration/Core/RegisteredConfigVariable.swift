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
struct RegisteredConfigVariable: Sendable {
    /// The configuration key used to look up this variable's value.
    let key: ConfigKey

    /// The variable's default value represented as a ``ConfigContent``.
    let defaultContent: ConfigContent

    /// Whether this value should be treated as a secret.
    let secrecy: ConfigVariableSecrecy

    /// The configuration variable's metadata.
    let metadata: ConfigVariableMetadata


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
