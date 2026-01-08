//
//  StructuredConfigReader.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 1/7/2026.
//

import Configuration
import DevFoundation

/// Provides structured access to configuration values queried by a `ConfigVariable`.
///
/// ## Usage
///
///     let providers: [any ConfigProvider] = [
///         EnvironmentVariablesProvider()
///     ]
///
///     let reader = StructuredConfigReader(
///         providers: providers,
///         eventBus: eventBus
///     )
///
///     let darkMode = reader.value(for: .darkMode)
///
/// TODO: Revisit top-level documentation
public final class StructuredConfigReader {
    /// The event bus that telemetry events are posted on.
    public let eventBus: EventBus

    /// The internal configuration reader that is used to resolve configuration values.
    private let reader: ConfigReader


    /// Creates a new `StructuredConfigReader` with the specified parameters.
    ///
    /// - Parameters:
    ///   - providers: The configuration providers, queried in order until a value is found.
    ///   - eventBus: The event bus that telemetry events are posted on.
    public init(providers: [any ConfigProvider], eventBus: EventBus) {
        self.eventBus = eventBus
        // TODO: Add TelemetryAccessReporter integration
        self.reader = ConfigReader(providers: providers)
    }
}


extension StructuredConfigReader: StructuredConfigReading {
    // MARK: - Primitive Types

    /// Gets the value for the specified `ConfigVariable<Bool>`.
    ///
    /// - Parameter variable: The variable to get a boolean value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public func value(for variable: ConfigVariable<Bool>) -> Bool {
        do {
            return try reader.requiredBool(
                forKey: variable.key,
                isSecret: variable.privacy.isPrivate
            )
        } catch {
            return variable.fallback
        }
    }


    /// Gets the value for the specified `ConfigVariable<String>`.
    ///
    /// - Parameter variable: The variable to get a string value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public func value(for variable: ConfigVariable<String>) -> String {
        do {
            return try reader.requiredString(
                forKey: variable.key,
                isSecret: variable.privacy.isPrivateForSensitiveTypes
            )
        } catch {
            return variable.fallback
        }
    }


    /// Gets the value for the specified `ConfigVariable<Int>`.
    ///
    /// - Parameter variable: The variable to get an integer value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public func value(for variable: ConfigVariable<Int>) -> Int {
        do {
            return try reader.requiredInt(
                forKey: variable.key,
                isSecret: variable.privacy.isPrivate
            )
        } catch {
            return variable.fallback
        }
    }


    /// Gets the value for the specified `ConfigVariable<Float64>`.
    ///
    /// - Parameter variable: The variable to get a float64 value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public func value(for variable: ConfigVariable<Float64>) -> Float64 {
        do {
            return try reader.requiredDouble(
                forKey: variable.key,
                isSecret: variable.privacy.isPrivate
            )
        } catch {
            return variable.fallback
        }
    }


    // MARK: - Array Types

    /// Gets the value for the specified `ConfigVariable<[Bool]>`.
    ///
    /// - Parameter variable: The variable to get a boolean array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public func value(for variable: ConfigVariable<[Bool]>) -> [Bool] {
        do {
            return try reader.requiredBoolArray(
                forKey: variable.key,
                isSecret: variable.privacy.isPrivate
            )
        } catch {
            return variable.fallback
        }
    }


    /// Gets the value for the specified `ConfigVariable<[String]>`.
    ///
    /// - Parameter variable: The variable to get a string array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public func value(for variable: ConfigVariable<[String]>) -> [String] {
        do {
            return try reader.requiredStringArray(
                forKey: variable.key,
                isSecret: variable.privacy.isPrivateForSensitiveTypes
            )
        } catch {
            return variable.fallback
        }
    }


    /// Gets the value for the specified `ConfigVariable<[Int]>`.
    ///
    /// - Parameter variable: The variable to get an integer array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public func value(for variable: ConfigVariable<[Int]>) -> [Int] {
        do {
            return try reader.requiredIntArray(
                forKey: variable.key,
                isSecret: variable.privacy.isPrivate
            )
        } catch {
            return variable.fallback
        }
    }


    /// Gets the value for the specified `ConfigVariable<[Float64]>`.
    ///
    /// - Parameter variable: The variable to get a float64 array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public func value(for variable: ConfigVariable<[Float64]>) -> [Float64] {
        do {
            return try reader.requiredDoubleArray(
                forKey: variable.key,
                isSecret: variable.privacy.isPrivate
            )
        } catch {
            return variable.fallback
        }
    }
}
