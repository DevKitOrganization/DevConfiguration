//
//  ConfigVariableReader.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 1/7/2026.
//

import Configuration
import DevFoundation

/// Provides structured access to configuration values queried by a `ConfigVariable`.
///
/// A config variable reader is a type-safe wrapper around swift-configuration's `ConfigReader`. It uses
/// `ConfigVariable` instances to provide compile-time type safety and structured access to configuration values.
/// The reader integrates with an access reporter to provide telemetry and observability for all configuration access.
///
/// To use a config variable reader, first define your configuration variables using ``ConfigVariable``. Each variable
/// specifies its key, type, default value, and secrecy level:
///
///     extension ConfigVariable where Value == Bool {
///         static let darkMode = ConfigVariable(
///             key: "dark_mode",
///             defaultValue: false,
///             secrecy: .auto
///         )
///     }
///
/// Then create a reader with your providers and query the variable:
///
///     let reader = ConfigVariableReader(
///         providers: [
///             InMemoryProvider(values: ["dark_mode": "true"])
///         ],
///         eventBus: eventBus
///     )
///
///     let darkMode = reader[.darkMode]  // true
///
/// The reader never throws. If resolution fails, it returns the variable's default value and posts a
/// ``ConfigVariableAccessFailedEvent`` to the event bus.
public struct ConfigVariableReader {
    /// The access reporter that is used to report configuration access events.
    public let accessReporter: any AccessReporter

    /// The configuration reader that is used to resolve configuration values.
    public let reader: ConfigReader

    /// The configuration reader's providers.
    ///
    /// This is stored so that
    public let providers: [any ConfigProvider]


    /// Creates a new `ConfigVariableReader` with the specified providers and the default telemetry access reporter.
    ///
    /// Use this initializer when you want to use the standard `EventBusAccessReporter`.
    ///
    /// - Parameters:
    ///   - providers: The configuration providers, queried in order until a value is found.
    ///   - eventBus: The event bus that telemetry events are posted on.
    public init(providers: [any ConfigProvider], eventBus: EventBus) {
        self.init(
            providers: providers,
            accessReporter: EventBusAccessReporter(eventBus: eventBus)
        )
    }


    /// Creates a new `ConfigVariableReader` with the specified providers and access reporter.
    ///
    /// Use this initializer when you want to directly control the access reporter used by the config reader.
    ///
    /// - Parameters:
    ///   - providers: The configuration providers, queried in order until a value is found.
    ///   - accessReporter: The access reporter that is used to report configuration access events.
    public init(providers: [any ConfigProvider], accessReporter: any AccessReporter) {
        self.accessReporter = accessReporter
        self.reader = ConfigReader(providers: providers, accessReporter: accessReporter)
        self.providers = providers
    }
}


// MARK: - Get

extension ConfigVariableReader {
    /// Gets the value for the specified `ConfigVariable`.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func value<Value>(
        for variable: ConfigVariable<Value>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> Value
    where Value: ConfigValueReadable {
        do {
            return try Value.requiredValue(
                forKey: variable.key,
                reader: reader,
                isSecret: variable.isSecret,
                fileID: fileID,
                line: line
            )
        } catch {
            return variable.defaultValue
        }
    }


    /// Gets the value for the specified array `ConfigVariable`.
    ///
    /// - Parameters:
    ///   - variable: The variable to get an array value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func value<Element>(
        for variable: ConfigVariable<[Element]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> [Element]
    where Element: ConfigValueReadable {
        do {
            return try Element.requiredArrayValue(
                forKey: variable.key,
                reader: reader,
                isSecret: variable.isSecret,
                fileID: fileID,
                line: line
            )
        } catch {
            return variable.defaultValue
        }
    }
}


// MARK: - Subscript Get

extension ConfigVariableReader {
    /// Gets the value for the specified `ConfigVariable`.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public subscript<Value>(
        variable: ConfigVariable<Value>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> Value
    where Value: ConfigValueReadable {
        value(for: variable, fileID: fileID, line: line)
    }


    /// Gets the value for the specified array `ConfigVariable`.
    ///
    /// - Parameters:
    ///   - variable: The variable to get an array value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public subscript<Element>(
        variable: ConfigVariable<[Element]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> [Element]
    where Element: ConfigValueReadable {
        value(for: variable, fileID: fileID, line: line)
    }
}


// MARK: - Fetch

extension ConfigVariableReader {
    /// Asynchronously fetches the value for the specified `ConfigVariable`.
    ///
    /// - Parameters:
    ///   - variable: The variable to fetch a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func fetchValue<Value>(
        for variable: ConfigVariable<Value>,
        fileID: String = #fileID,
        line: UInt = #line
    ) async -> Value
    where Value: ConfigValueReadable {
        do {
            return try await Value.fetchRequiredValue(
                forKey: variable.key,
                reader: reader,
                isSecret: variable.isSecret,
                fileID: fileID,
                line: line
            )
        } catch {
            return variable.defaultValue
        }
    }


    /// Asynchronously fetches the value for the specified array `ConfigVariable`.
    ///
    /// - Parameters:
    ///   - variable: The variable to fetch an array value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func fetchValue<Element>(
        for variable: ConfigVariable<[Element]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) async -> [Element]
    where Element: ConfigValueReadable {
        do {
            return try await Element.fetchRequiredArrayValue(
                forKey: variable.key,
                reader: reader,
                isSecret: variable.isSecret,
                fileID: fileID,
                line: line
            )
        } catch {
            return variable.defaultValue
        }
    }
}


// MARK: - Watch

extension ConfigVariableReader {
    /// Watches for updates to the value for the specified `ConfigVariable`.
    ///
    /// - Parameters:
    ///   - variable: The variable to watch for updates.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    ///   - updatesHandler: A closure that handles an async sequence of updates to the value.
    /// - Returns: The result produced by the handler.
    public func watchValue<Value, Return>(
        for variable: ConfigVariable<Value>,
        fileID: String = #fileID,
        line: UInt = #line,
        updatesHandler: (_ updates: any AsyncSequence<Value, Never>) async throws -> Return
    ) async throws -> Return
    where Value: ConfigValueReadable, Return: ~Copyable {
        try await Value.watchValue(
            forKey: variable.key,
            reader: reader,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }


    /// Watches for updates to the value for the specified array `ConfigVariable`.
    ///
    /// - Parameters:
    ///   - variable: The variable to watch for updates.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    ///   - updatesHandler: A closure that handles an async sequence of updates to the value.
    /// - Returns: The result produced by the handler.
    public func watchValue<Element, Return>(
        for variable: ConfigVariable<[Element]>,
        fileID: String = #fileID,
        line: UInt = #line,
        updatesHandler: (_ updates: any AsyncSequence<[Element], Never>) async throws -> Return
    ) async throws -> Return
    where Element: ConfigValueReadable, Return: ~Copyable {
        try await Element.watchArrayValue(
            forKey: variable.key,
            reader: reader,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }
}
