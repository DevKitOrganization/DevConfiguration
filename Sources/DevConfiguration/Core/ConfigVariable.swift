//
//  ConfigVariable.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 1/7/2026.
//

import Configuration

/// A type-safe variable definition with a default value.
///
/// `ConfigVariable` encapsulates a configuration key and its default value, providing compile-time type safety for
/// configuration access.
///
/// ## Usage
///
/// Define configuration variables as static properties:
///
/// ```swift
/// extension ConfigVariable where Value == Bool {
///     static let darkMode = ConfigVariable(
///         key: "feature.darkMode",
///         defaultValue: false
///     )
/// }
/// ```
///
/// Access values through a `StructuredConfigReading` instance:
///
/// ```swift
/// let darkMode = reader[.darkMode]
/// ```
public struct ConfigVariable<Value>: Sendable where Value: Sendable {
    /// The configuration key used to look up this variable's value.
    public let key: ConfigKey

    /// The default value returned when the variable cannot be resolved.
    public let defaultValue: Value

    /// Whether this value should be treated as a secret.
    public let secrecy: ConfigVariableSecrecy


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
