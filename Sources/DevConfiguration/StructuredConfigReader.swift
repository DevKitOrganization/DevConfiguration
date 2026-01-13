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
/// A structured config reader is a type-safe wrapper around swift-configuration's `ConfigReader`. It uses
/// `ConfigVariable` instances to provide compile-time type safety and structured access to configuration values.
/// The reader integrates with an access reporter to provide telemetry and observability for all configuration access.
///
/// To use a structured config reader, first define your configuration variables using `ConfigVariable`. Each variable
/// specifies its key, type, fallback value, and privacy level:
///
///     extension ConfigVariable where Value == Bool {
///         static let darkMode = ConfigVariable(
///             key: "dark_mode",
///             fallback: false,
///             privacy: .auto
///         )
///     }
///
/// Then create a reader with your providers and query the variable:
///
///     let reader = StructuredConfigReader(
///         providers: [
///             InMemoryProvider(values: ["dark_mode": "true"])
///         ],
///         eventBus: eventBus
///     )
///
///     let darkMode = reader[.darkMode]  // true
///
/// The reader never throws. If resolution fails, it returns the variable's fallback value and posts a
/// `DidFailToAccessVariableBusEvent` to the event bus.
public final class StructuredConfigReader {
    /// The access reporter that is used to report configuration access events.
    public let accessReporter: any AccessReporter

    /// The internal configuration reader that is used to resolve configuration values.
    let reader: ConfigReader


    /// Creates a new `StructuredConfigReader` with the specified providers and the default telemetry access reporter.
    ///
    /// Use this initializer when you want to use the standard `TelemetryAccessReporter`.
    ///
    /// - Parameters:
    ///   - providers: The configuration providers, queried in order until a value is found.
    ///   - eventBus: The event bus that telemetry events are posted on.
    public convenience init(providers: [any ConfigProvider], eventBus: EventBus) {
        self.init(
            providers: providers,
            accessReporter: TelemetryAccessReporter(eventBus: eventBus)
        )
    }


    /// Creates a new `StructuredConfigReader` with the specified providers and access reporter.
    ///
    /// Use this initializer when you want to directly control the access reporter used by the config reader.
    ///
    /// - Parameters:
    ///   - providers: The configuration providers, queried in order until a value is found.
    ///   - accessReporter: The access reporter that is used to report configuration access events.
    public init(providers: [any ConfigProvider], accessReporter: any AccessReporter) {
        self.accessReporter = accessReporter
        self.reader = ConfigReader(providers: providers, accessReporter: accessReporter)
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
