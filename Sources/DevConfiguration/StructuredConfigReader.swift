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
public final class StructuredConfigReader {
    /// TODO: document.
    public let eventBus: EventBus

    /// TODO: document.
    private let reader: ConfigReader


    /// Creates a new `StructuredConfigReader` with the specified parameters.
    ///
    /// - Parameters:
    ///   - providers: The configuration providers, queried in order until a value is found.
    ///   - eventBus: Event bus for telemetry emission.
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
            // TODO: Pass isSecret parameter based on variable.privacy
            let resolved = try reader.requiredBool(forKey: variable.key, isSecret: false)
            // TODO: TelemetryAccessReporter posts success telemetry automatically
            return resolved
        } catch {
            // TODO: Post VariableResolutionFailedBusEvent
            return variable.fallback
        }
    }


    /// Gets the value for the specified `ConfigVariable<String>`.
    ///
    /// - Parameter variable: The variable to get a string value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public func value(for variable: ConfigVariable<String>) -> String {
        do {
            // TODO: Pass isSecret parameter based on variable.privacy
            let resolved = try reader.requiredString(forKey: variable.key, isSecret: false)
            // TODO: TelemetryAccessReporter posts success telemetry automatically
            return resolved
        } catch {
            // TODO: Post VariableResolutionFailedBusEvent
            return variable.fallback
        }
    }


    /// Gets the value for the specified `ConfigVariable<Int>`.
    ///
    /// - Parameter variable: The variable to get an integer value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public func value(for variable: ConfigVariable<Int>) -> Int {
        do {
            // TODO: Pass isSecret parameter based on variable.privacy
            let resolved = try reader.requiredInt(forKey: variable.key, isSecret: false)
            // TODO: TelemetryAccessReporter posts success telemetry automatically
            return resolved
        } catch {
            // TODO: Post VariableResolutionFailedBusEvent
            return variable.fallback
        }
    }


    /// Gets the value for the specified `ConfigVariable<Float64>`.
    ///
    /// - Parameter variable: The variable to get a float64 value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public func value(for variable: ConfigVariable<Float64>) -> Float64 {
        do {
            // TODO: Pass isSecret parameter based on variable.privacy
            let resolved = try reader.requiredDouble(forKey: variable.key, isSecret: false)
            // TODO: TelemetryAccessReporter posts success telemetry automatically
            return resolved
        } catch {
            // TODO: Post VariableResolutionFailedBusEvent
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
            // TODO: Pass isSecret parameter based on variable.privacy
            let resolved = try reader.requiredBoolArray(forKey: variable.key, isSecret: false)
            // TODO: TelemetryAccessReporter posts success telemetry automatically
            return resolved
        } catch {
            // TODO: Post VariableResolutionFailedBusEvent
            return variable.fallback
        }
    }


    /// Gets the value for the specified `ConfigVariable<[String]>`.
    ///
    /// - Parameter variable: The variable to get a string array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public func value(for variable: ConfigVariable<[String]>) -> [String] {
        do {
            // TODO: Pass isSecret parameter based on variable.privacy
            let resolved = try reader.requiredStringArray(forKey: variable.key, isSecret: false)
            // TODO: TelemetryAccessReporter posts success telemetry automatically
            return resolved
        } catch {
            // TODO: Post VariableResolutionFailedBusEvent
            return variable.fallback
        }
    }


    /// Gets the value for the specified `ConfigVariable<[Int]>`.
    ///
    /// - Parameter variable: The variable to get an integer array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public func value(for variable: ConfigVariable<[Int]>) -> [Int] {
        do {
            // TODO: Pass isSecret parameter based on variable.privacy
            let resolved = try reader.requiredIntArray(forKey: variable.key, isSecret: false)
            // TODO: TelemetryAccessReporter posts success telemetry automatically
            return resolved
        } catch {
            // TODO: Post VariableResolutionFailedBusEvent
            return variable.fallback
        }
    }


    /// Gets the value for the specified `ConfigVariable<[Float64]>`.
    ///
    /// - Parameter variable: The variable to get a float64 array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public func value(for variable: ConfigVariable<[Float64]>) -> [Float64] {
        do {
            // TODO: Pass isSecret parameter based on variable.privacy
            let resolved = try reader.requiredDoubleArray(forKey: variable.key, isSecret: false)
            // TODO: TelemetryAccessReporter posts success telemetry automatically
            return resolved
        } catch {
            // TODO: Post VariableResolutionFailedBusEvent
            return variable.fallback
        }
    }
}
