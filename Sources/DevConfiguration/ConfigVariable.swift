//
//  ConfigVariable.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 1/7/2026.
//

import Configuration

/// A type-safe variable definition with a fallback value.
///
/// `ConfigVariable` encapsulates a configuration key and its fallback value,
/// providing compile-time type safety for configuration access.
///
/// ## Usage
///
/// Define configuration variables as static properties:
///
/// ```swift
/// extension ConfigVariable where Value == Bool {
///     static let darkMode = ConfigVariable(
///         key: "feature.darkMode",
///         fallback: false
///     )
/// }
/// ```
///
/// Access values through a `StructuredConfigurationReading` instance:
///
/// ```swift
/// let darkMode = reader.value(for: .darkMode)
/// ```
public struct ConfigVariable<Value> {
    /// The configuration key used to look up this variable's value.
    public let key: ConfigKey

    /// The fallback value returned when the variable cannot be resolved.
    public let fallback: Value

    /// Whether this value should be treated as a secret.
    public let privacy: VariablePrivacy


    /// Creates a configuration variable with the specified string key.
    ///
    /// The string is converted to a `ConfigKey` using the default initializer.
    ///
    /// - Parameters:
    ///   - key: The configuration key as a string (e.g., "feature.darkMode").
    ///   - fallback: The fallback value to use when variable resolution fails.
    ///   - privacy: The privacy setting for this variable. Defaults to `.auto`.
    public init(key: String, fallback: Value, privacy: VariablePrivacy = .auto) {
        self.init(key: ConfigKey(key), fallback: fallback, privacy: privacy)
    }


    /// Creates a configuration variable with the specified `ConfigKey`.
    ///
    /// Use this initializer when you need to specified the `ConfigKey` directly.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - fallback: The fallback value to use when variable resolution fails.
    ///   - privacy: The privacy setting for this variable. Defaults to `.auto`.
    public init(key: ConfigKey, fallback: Value, privacy: VariablePrivacy = .auto) {
        self.key = key
        self.fallback = fallback
        self.privacy = privacy
    }
}
