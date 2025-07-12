//
//  ConfigurationVariable.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 7/12/25.
//

import Foundation

/// A client-side key for accessing configuration variable values.
///
/// `ConfigurationVariable` instances are defined by the application and used as keys to retrieve
/// values from a configuration data source. Define a `ConfigurationVariable` with the name
/// and type of a variable to query the data source for a value.
///
/// Example:
///
///     let applePayEnabledVariable = ConfigurationVariable(
///         name: "isApplePayEnabled",
///         fallbackValue: true
///     )
///
///     let isApplePayEnabled = configurationDataSource.value(
///         for: applePayEnabledVariable
///     )
///
/// An application-defined fallback value is required so that a configuration data source
/// can always supply a value for a given variable in various degraded states. For instance, if a
/// variable's type and its remote value's type are mismatched, the application-defined fallback is
/// used. Similarly, if the variable's type conforms to `Codable` but the data source fails to
/// decode the remote value into the type, the fallback is used.
///
/// The DevConfiguration library supports the following configuration variable types:
///   - `Bool`
///   - `Int`
///   - `Double`
///   - `String`
///   - `Codable`
///
@dynamicMemberLookup
public struct ConfigurationVariable<Value>: Equatable, Sendable where Value: Codable & Equatable & Sendable {
    /// The name of the variable as defined by the configuration source.
    public let name: VariableName

    /// A value to use for the variable in fallback scenarios.
    public let fallbackValue: Value

    /// The instance's metadata.
    private(set) var metadata: VariableMetadata = VariableMetadata()


    /// Creates a new `ConfigurationVariable` instance with the specified name and fallback value.
    ///
    /// - Parameters:
    ///   - name: The name of the variable as defined by the configuration source.
    ///   - fallbackValue: A value to use for the variable in fallback scenarios.
    public init(name: String, fallbackValue: Value) {
        self.name = VariableName(name)
        self.fallbackValue = fallbackValue
    }


    /// Creates a new `ConfigurationVariable` instance with the specified name and fallback value.
    ///
    /// - Parameters:
    ///   - name: The name of the variable as defined by the configuration source.
    ///   - fallbackValue: A value to use for the variable in fallback scenarios.
    public init(name: VariableName, fallbackValue: Value) {
        self.name = name
        self.fallbackValue = fallbackValue
    }


    // MARK: - Variable Metadata

    /// Returns an instance of `ConfigurationVariable` with the specified metadata.
    ///
    /// Use this method to construct a configuration variable with some additional metadata.
    ///
    ///     let variable = ConfigurationVariable(name: "variable1", fallbackValue: false)
    ///         .metadata(\.owningTeam, .team1)
    ///         .metadata(\.jiraEpic, "ABCD-1234")
    ///         .metadata(\.expirationDate, Date.now + TimeInterval(5 * 86400))
    ///
    /// - Parameters:
    ///   - keyPath: A keypath for the metadata value.
    ///   - value: The metadata value to store.
    /// - Returns: A new instance containing the specified metadata.
    public func metadata<MetadataValue>(
        _ keyPath: WritableKeyPath<VariableMetadata, MetadataValue>,
        _ value: MetadataValue
    ) -> Self {
        var copy = self
        copy.metadata[keyPath: keyPath] = value
        return copy
    }


    /// Returns the metadata value associated with the metadata key.
    ///
    /// Typically this subscript is used implicitly via the dynamic member syntax, for example:
    ///
    ///     let expirationDate = variable.expirationDate
    ///
    /// which returns the value stored via a hypothetical, user-defined
    /// `VariableMetadata.expirationDate` key.
    public subscript<MetadataValue>(
        dynamicMember keyPath: WritableKeyPath<VariableMetadata, MetadataValue>
    ) -> MetadataValue {
        get { return metadata[keyPath: keyPath] }
        set { metadata[keyPath: keyPath] = newValue }
    }
}
