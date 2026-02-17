//
//  ConfigVariable.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 1/7/2026.
//

import Configuration

/// A type-safe variable definition with a default value.
///
/// `ConfigVariable` encapsulates a configuration key, its default value, its secrecy, and any custom metadata that
/// might be attached to it. Using configuration variables ensures that variables will be read using the correct type
/// and default value.
///
/// ``ConfigVariableReader``s are used to read the value of a config variable. While `ConfigVariable` is a generic type,
/// `ConfigVariableReader` only supports reading variables whose `Value` is one of:
///
/// - `Bool`
/// - `Data`
/// - `Float64` or `Double`
/// - `Int`
/// - `String`
/// - `[Bool]`
/// - `[Data]`
/// - `[Float64]` or `[Double]`
/// - `[Int]`
/// - `[String]`
@dynamicMemberLookup
public struct ConfigVariable<Value>: Sendable where Value: Sendable {
    /// The configuration key used to look up this variable's value.
    public let key: ConfigKey

    /// The default value returned when the variable cannot be resolved.
    public let defaultValue: Value

    /// Whether this value should be treated as a secret.
    public let secrecy: ConfigVariableSecrecy

    /// The configuration variable’s metadata.
    private(set) var metadata = ConfigVariableMetadata()


    /// Creates a configuration variable with the specified `ConfigKey`.
    ///
    /// Use this initializer when you need to specified the `ConfigKey` directly.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - secrecy: The secrecy setting for this variable. Defaults to `.auto`.
    public init(key: ConfigKey, defaultValue: Value, secrecy: ConfigVariableSecrecy = .auto) {
        self.key = key
        self.defaultValue = defaultValue
        self.secrecy = secrecy
    }


    /// Sets a metadata value on this configuration variable using a keypath.
    ///
    /// This function allows you to attach metadata to a configuration variable using a fluent builder pattern. Metadata
    /// can include any custom metadata defined in ``ConfigVariableMetadata``.
    ///
    ///     let variable = ConfigVariable(key: "feature.darkMode", defaultValue: false)
    ///         .metadata(\.owningTeam, .alpha)
    ///         .metadata(\.project, "Onboarding")
    ///         .metadata(\.expirationDate, DateComponents(year: 2026, month: 2, day: 16))
    ///
    /// - Parameters:
    ///   - keyPath: A writable keypath to the metadata property on `ConfigVariableMetadata`.
    ///   - value: The value to set for the metadata property.
    /// - Returns: A copy of the `ConfigVariable` with the metadata value applied.
    public func metadata<MetadataValue>(
        _ keyPath: WritableKeyPath<ConfigVariableMetadata, MetadataValue>,
        _ value: MetadataValue
    ) -> Self {
        var copy = self
        copy.metadata[keyPath: keyPath] = value
        return copy
    }


    /// Provides dynamic member lookup access to metadata properties.
    ///
    /// This subscript enables dot-syntax access to metadata properties. It provides both read and write access to any
    /// property on ``ConfigVariableMetadata``.
    ///
    ///     var variable = ConfigVariable(key: "feature.darkMode", defaultValue: false)
    ///     variable.owningTeam = .alpha
    ///     variable.project = "Onboarding"
    ///     let team = variable.owningTeam
    ///
    /// - Parameter keyPath: A writable keypath to a property on `ConfigVariableMetadata`.
    /// - Returns: The value of the metadata property.
    public subscript<MetadataValue>(
        dynamicMember keyPath: WritableKeyPath<ConfigVariableMetadata, MetadataValue>
    ) -> MetadataValue {
        get { return metadata[keyPath: keyPath] }
        set { metadata[keyPath: keyPath] = newValue }
    }
}


extension ConfigVariable {
    /// Creates a configuration variable with the specified string key.
    ///
    /// The string is converted to a `ConfigKey` using the default initializer.
    ///
    /// - Parameters:
    ///   - key: The configuration key as a string (e.g., "feature.darkMode").
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - secrecy: The secrecy setting for this variable. Defaults to `.auto`.
    public init(key: String, defaultValue: Value, secrecy: ConfigVariableSecrecy = .auto) {
        self.init(key: ConfigKey(key), defaultValue: defaultValue, secrecy: secrecy)
    }
}
