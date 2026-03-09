//
//  ConfigVariable.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 1/7/2026.
//

import Configuration

/// A type-safe variable definition with a default value.
///
/// `ConfigVariable` encapsulates a configuration key, its default value, its content, its secrecy, and any custom
/// metadata that might be attached to it. Using configuration variables ensures that variables will be read using the
/// correct type and default value.
///
/// For primitive types, create a variable without specifying content — the appropriate content is set automatically:
///
///     static let timeout = ConfigVariable(key: "timeout", defaultValue: 30)
///     static let darkMode = ConfigVariable(key: "feature.darkMode", defaultValue: false)
///
/// For `Codable` types, specify the content explicitly:
///
///     static let experiment = ConfigVariable(
///         key: "experiment.onboarding",
///         defaultValue: ExperimentConfig.default,
///         content: .json()
///     )
@dynamicMemberLookup
public struct ConfigVariable<Value>: Sendable where Value: Sendable {
    /// A typealias for the content type associated with this variable’s value type.
    public typealias Content = ConfigVariableContent<Value>

    /// The configuration key used to look up this variable’s value.
    public let key: ConfigKey

    /// The default value returned when the variable cannot be resolved.
    public let defaultValue: Value

    /// Describes how this variable’s value maps to and from `ConfigContent` primitives.
    public let content: Content

    /// Whether this variable’s value should be treated as secret.
    ///
    /// Secret values are redacted or obfuscated in telemetry, logging, and other observability systems to prevent
    /// sensitive information from being exposed. Defaults to `false`.
    public let isSecret: Bool

    /// The configuration variable’s metadata.
    private(set) var metadata = ConfigVariableMetadata()


    /// Creates a configuration variable with the specified `ConfigKey` and content.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - content: Describes how the value maps to and from `ConfigContent` primitives.
    ///   - isSecret: Whether this variable’s value should be treated as secret. Defaults to `false`.
    public init(key: ConfigKey, defaultValue: Value, content: Content, isSecret: Bool = false) {
        self.key = key
        self.defaultValue = defaultValue
        self.content = content
        self.isSecret = isSecret
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


// MARK: - Primitive Initializers

extension ConfigVariable where Value == Bool {
    /// Creates a `Bool` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/bool`` automatically.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init(key: ConfigKey, defaultValue: Bool, isSecret: Bool = false) {
        self.init(key: key, defaultValue: defaultValue, content: .bool, isSecret: isSecret)
    }
}


extension ConfigVariable where Value == [Bool] {
    /// Creates a `[Bool]` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/boolArray`` automatically.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init(key: ConfigKey, defaultValue: [Bool], isSecret: Bool = false) {
        self.init(key: key, defaultValue: defaultValue, content: .boolArray, isSecret: isSecret)
    }
}


extension ConfigVariable where Value == Float64 {
    /// Creates a `Float64` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/float64`` automatically.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init(key: ConfigKey, defaultValue: Float64, isSecret: Bool = false) {
        self.init(key: key, defaultValue: defaultValue, content: .float64, isSecret: isSecret)
    }
}


extension ConfigVariable where Value == [Float64] {
    /// Creates a `[Float64]` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/float64Array`` automatically.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init(key: ConfigKey, defaultValue: [Float64], isSecret: Bool = false) {
        self.init(key: key, defaultValue: defaultValue, content: .float64Array, isSecret: isSecret)
    }
}


extension ConfigVariable where Value == Int {
    /// Creates an `Int` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/int`` automatically.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init(key: ConfigKey, defaultValue: Int, isSecret: Bool = false) {
        self.init(key: key, defaultValue: defaultValue, content: .int, isSecret: isSecret)
    }
}


extension ConfigVariable where Value == [Int] {
    /// Creates an `[Int]` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/intArray`` automatically.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init(key: ConfigKey, defaultValue: [Int], isSecret: Bool = false) {
        self.init(key: key, defaultValue: defaultValue, content: .intArray, isSecret: isSecret)
    }
}


extension ConfigVariable where Value == String {
    /// Creates a `String` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/string`` automatically.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init(key: ConfigKey, defaultValue: String, isSecret: Bool = false) {
        self.init(key: key, defaultValue: defaultValue, content: .string, isSecret: isSecret)
    }
}


extension ConfigVariable where Value == [String] {
    /// Creates a `[String]` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/stringArray`` automatically.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init(key: ConfigKey, defaultValue: [String], isSecret: Bool = false) {
        self.init(key: key, defaultValue: defaultValue, content: .stringArray, isSecret: isSecret)
    }
}


extension ConfigVariable where Value == [UInt8] {
    /// Creates a `[UInt8]` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/bytes`` automatically.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init(key: ConfigKey, defaultValue: [UInt8], isSecret: Bool = false) {
        self.init(key: key, defaultValue: defaultValue, content: .bytes, isSecret: isSecret)
    }
}


extension ConfigVariable where Value == [[UInt8]] {
    /// Creates a `[[UInt8]]` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/byteChunkArray`` automatically.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init(key: ConfigKey, defaultValue: [[UInt8]], isSecret: Bool = false) {
        self.init(key: key, defaultValue: defaultValue, content: .byteChunkArray, isSecret: isSecret)
    }
}


// MARK: - String-Convertible Initializers

extension ConfigVariable {
    /// Creates a `RawRepresentable<String>` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/rawRepresentableString()`` automatically. The value is resolved by
    /// reading a string from the provider and converting it using the type’s `RawRepresentable` conformance.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init(key: ConfigKey, defaultValue: Value, isSecret: Bool = false)
    where Value: RawRepresentable & Sendable, Value.RawValue == String {
        self.init(key: key, defaultValue: defaultValue, content: .rawRepresentableString(), isSecret: isSecret)
    }
}


extension ConfigVariable {
    /// Creates a `[RawRepresentable<String>]` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/rawRepresentableStringArray()`` automatically.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init<Element>(key: ConfigKey, defaultValue: [Element], isSecret: Bool = false)
    where Value == [Element], Element: RawRepresentable & Sendable, Element.RawValue == String {
        self.init(key: key, defaultValue: defaultValue, content: .rawRepresentableStringArray(), isSecret: isSecret)
    }
}


extension ConfigVariable {
    /// Creates an `ExpressibleByConfigString` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/expressibleByConfigString()`` automatically. The value is resolved by
    /// reading a string from the provider and converting it using the type’s `ExpressibleByConfigString` conformance.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init(key: ConfigKey, defaultValue: Value, isSecret: Bool = false)
    where Value: ExpressibleByConfigString {
        self.init(key: key, defaultValue: defaultValue, content: .expressibleByConfigString(), isSecret: isSecret)
    }
}


extension ConfigVariable {
    /// Creates a `[ExpressibleByConfigString]` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/expressibleByConfigStringArray()`` automatically.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init<Element>(key: ConfigKey, defaultValue: [Element], isSecret: Bool = false)
    where Value == [Element], Element: ExpressibleByConfigString & Sendable {
        self.init(key: key, defaultValue: defaultValue, content: .expressibleByConfigStringArray(), isSecret: isSecret)
    }
}


// MARK: - Int-Convertible Initializers

extension ConfigVariable {
    /// Creates a `RawRepresentable<Int>` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/rawRepresentableInt()`` automatically. The value is resolved by
    /// reading an integer from the provider and converting it using the type’s `RawRepresentable` conformance.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init(key: ConfigKey, defaultValue: Value, isSecret: Bool = false)
    where Value: RawRepresentable & Sendable, Value.RawValue == Int {
        self.init(key: key, defaultValue: defaultValue, content: .rawRepresentableInt(), isSecret: isSecret)
    }
}


extension ConfigVariable {
    /// Creates a `[RawRepresentable<Int>]` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/rawRepresentableIntArray()`` automatically.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init<Element>(key: ConfigKey, defaultValue: [Element], isSecret: Bool = false)
    where Value == [Element], Element: RawRepresentable & Sendable, Element.RawValue == Int {
        self.init(key: key, defaultValue: defaultValue, content: .rawRepresentableIntArray(), isSecret: isSecret)
    }
}


extension ConfigVariable {
    /// Creates an `ExpressibleByConfigInt` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/expressibleByConfigInt()`` automatically. The value is resolved by
    /// reading an integer from the provider and converting it using the type’s `ExpressibleByConfigInt` conformance.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init(key: ConfigKey, defaultValue: Value, isSecret: Bool = false)
    where Value: ExpressibleByConfigInt {
        self.init(key: key, defaultValue: defaultValue, content: .expressibleByConfigInt(), isSecret: isSecret)
    }
}


extension ConfigVariable {
    /// Creates a `[ExpressibleByConfigInt]` configuration variable.
    ///
    /// Content is set to ``ConfigVariableContent/expressibleByConfigIntArray()`` automatically.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultValue: The default value to use when variable resolution fails.
    ///   - isSecret: Whether this variable's value should be treated as secret. Defaults to `false`.
    public init<Element>(key: ConfigKey, defaultValue: [Element], isSecret: Bool = false)
    where Value == [Element], Element: ExpressibleByConfigInt & Sendable {
        self.init(key: key, defaultValue: defaultValue, content: .expressibleByConfigIntArray(), isSecret: isSecret)
    }
}
