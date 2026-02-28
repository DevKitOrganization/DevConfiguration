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
    /// Gets the value for the specified `Bool` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func value(
        for variable: ConfigVariable<Bool>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> Bool {
        return reader.bool(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Gets the value for the specified `[Bool]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func value(
        for variable: ConfigVariable<[Bool]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> [Bool] {
        return reader.boolArray(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Gets the value for the specified `Float64` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func value(
        for variable: ConfigVariable<Float64>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> Float64 {
        return reader.double(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Gets the value for the specified `[Float64]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func value(
        for variable: ConfigVariable<[Float64]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> [Float64] {
        return reader.doubleArray(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Gets the value for the specified `Int` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func value(
        for variable: ConfigVariable<Int>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> Int {
        return reader.int(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Gets the value for the specified `[Int]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func value(
        for variable: ConfigVariable<[Int]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> [Int] {
        return reader.intArray(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Gets the value for the specified `String` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func value(
        for variable: ConfigVariable<String>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> String {
        return reader.string(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Gets the value for the specified `[String]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func value(
        for variable: ConfigVariable<[String]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> [String] {
        return reader.stringArray(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Gets the value for the specified `[UInt8]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func value(
        for variable: ConfigVariable<[UInt8]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> [UInt8] {
        return reader.bytes(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Gets the value for the specified `[[UInt8]]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func value(
        for variable: ConfigVariable<[[UInt8]]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> [[UInt8]] {
        return reader.byteChunkArray(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }
}


// MARK: - Subscript Get

extension ConfigVariableReader {
    /// Gets the value for the specified `Bool` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public subscript(
        variable: ConfigVariable<Bool>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> Bool {
        value(for: variable, fileID: fileID, line: line)
    }


    /// Gets the value for the specified `[Bool]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public subscript(
        variable: ConfigVariable<[Bool]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> [Bool] {
        value(for: variable, fileID: fileID, line: line)
    }


    /// Gets the value for the specified `Float64` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public subscript(
        variable: ConfigVariable<Float64>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> Float64 {
        value(for: variable, fileID: fileID, line: line)
    }


    /// Gets the value for the specified `[Float64]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public subscript(
        variable: ConfigVariable<[Float64]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> [Float64] {
        value(for: variable, fileID: fileID, line: line)
    }


    /// Gets the value for the specified `Int` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public subscript(
        variable: ConfigVariable<Int>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> Int {
        value(for: variable, fileID: fileID, line: line)
    }


    /// Gets the value for the specified `[Int]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public subscript(
        variable: ConfigVariable<[Int]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> [Int] {
        value(for: variable, fileID: fileID, line: line)
    }


    /// Gets the value for the specified `String` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public subscript(
        variable: ConfigVariable<String>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> String {
        value(for: variable, fileID: fileID, line: line)
    }


    /// Gets the value for the specified `[String]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public subscript(
        variable: ConfigVariable<[String]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> [String] {
        value(for: variable, fileID: fileID, line: line)
    }


    /// Gets the value for the specified `[UInt8]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public subscript(
        variable: ConfigVariable<[UInt8]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> [UInt8] {
        value(for: variable, fileID: fileID, line: line)
    }


    /// Gets the value for the specified `[[UInt8]]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public subscript(
        variable: ConfigVariable<[[UInt8]]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> [[UInt8]] {
        value(for: variable, fileID: fileID, line: line)
    }
}


// MARK: - Fetch

extension ConfigVariableReader {
    /// Asynchronously fetches the value for the specified `Bool` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to fetch a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func fetchValue(
        for variable: ConfigVariable<Bool>,
        fileID: String = #fileID,
        line: UInt = #line
    ) async throws -> Bool {
        return try await reader.fetchBool(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Asynchronously fetches the value for the specified `[Bool]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to fetch a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func fetchValue(
        for variable: ConfigVariable<[Bool]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) async throws -> [Bool] {
        return try await reader.fetchBoolArray(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Asynchronously fetches the value for the specified `Float64` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to fetch a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func fetchValue(
        for variable: ConfigVariable<Float64>,
        fileID: String = #fileID,
        line: UInt = #line
    ) async throws -> Float64 {
        return try await reader.fetchDouble(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Asynchronously fetches the value for the specified `[Float64]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to fetch a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func fetchValue(
        for variable: ConfigVariable<[Float64]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) async throws -> [Float64] {
        return try await reader.fetchDoubleArray(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Asynchronously fetches the value for the specified `Int` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to fetch a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func fetchValue(
        for variable: ConfigVariable<Int>,
        fileID: String = #fileID,
        line: UInt = #line
    ) async throws -> Int {
        return try await reader.fetchInt(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Asynchronously fetches the value for the specified `[Int]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to fetch a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func fetchValue(
        for variable: ConfigVariable<[Int]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) async throws -> [Int] {
        return try await reader.fetchIntArray(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Asynchronously fetches the value for the specified `String` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to fetch a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func fetchValue(
        for variable: ConfigVariable<String>,
        fileID: String = #fileID,
        line: UInt = #line
    ) async throws -> String {
        return try await reader.fetchString(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Asynchronously fetches the value for the specified `[String]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to fetch a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func fetchValue(
        for variable: ConfigVariable<[String]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) async throws -> [String] {
        return try await reader.fetchStringArray(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Asynchronously fetches the value for the specified `[UInt8]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to fetch a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func fetchValue(
        for variable: ConfigVariable<[UInt8]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) async throws -> [UInt8] {
        return try await reader.fetchBytes(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }


    /// Asynchronously fetches the value for the specified `[[UInt8]]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to fetch a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public func fetchValue(
        for variable: ConfigVariable<[[UInt8]]>,
        fileID: String = #fileID,
        line: UInt = #line
    ) async throws -> [[UInt8]] {
        return try await reader.fetchByteChunkArray(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line
        )
    }
}


// MARK: - Watch

extension ConfigVariableReader {
    /// Watches for updates to the value for the specified `Bool` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to watch for updates.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    ///   - updatesHandler: A closure that handles an async sequence of updates to the value.
    /// - Returns: The result produced by the handler.
    public func watchValue<Return: ~Copyable>(
        for variable: ConfigVariable<Bool>,
        fileID: String = #fileID,
        line: UInt = #line,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<Bool, Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchBool(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }


    /// Watches for updates to the value for the specified `[Bool]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to watch for updates.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    ///   - updatesHandler: A closure that handles an async sequence of updates to the value.
    /// - Returns: The result produced by the handler.
    public func watchValue<Return: ~Copyable>(
        for variable: ConfigVariable<[Bool]>,
        fileID: String = #fileID,
        line: UInt = #line,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<[Bool], Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchBoolArray(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }


    /// Watches for updates to the value for the specified `Float64` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to watch for updates.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    ///   - updatesHandler: A closure that handles an async sequence of updates to the value.
    /// - Returns: The result produced by the handler.
    public func watchValue<Return: ~Copyable>(
        for variable: ConfigVariable<Float64>,
        fileID: String = #fileID,
        line: UInt = #line,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<Float64, Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchDouble(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }


    /// Watches for updates to the value for the specified `[Float64]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to watch for updates.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    ///   - updatesHandler: A closure that handles an async sequence of updates to the value.
    /// - Returns: The result produced by the handler.
    public func watchValue<Return: ~Copyable>(
        for variable: ConfigVariable<[Float64]>,
        fileID: String = #fileID,
        line: UInt = #line,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<[Float64], Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchDoubleArray(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }


    /// Watches for updates to the value for the specified `Int` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to watch for updates.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    ///   - updatesHandler: A closure that handles an async sequence of updates to the value.
    /// - Returns: The result produced by the handler.
    public func watchValue<Return: ~Copyable>(
        for variable: ConfigVariable<Int>,
        fileID: String = #fileID,
        line: UInt = #line,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<Int, Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchInt(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }


    /// Watches for updates to the value for the specified `[Int]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to watch for updates.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    ///   - updatesHandler: A closure that handles an async sequence of updates to the value.
    /// - Returns: The result produced by the handler.
    public func watchValue<Return: ~Copyable>(
        for variable: ConfigVariable<[Int]>,
        fileID: String = #fileID,
        line: UInt = #line,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<[Int], Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchIntArray(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }


    /// Watches for updates to the value for the specified `String` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to watch for updates.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    ///   - updatesHandler: A closure that handles an async sequence of updates to the value.
    /// - Returns: The result produced by the handler.
    public func watchValue<Return: ~Copyable>(
        for variable: ConfigVariable<String>,
        fileID: String = #fileID,
        line: UInt = #line,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<String, Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchString(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }


    /// Watches for updates to the value for the specified `[String]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to watch for updates.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    ///   - updatesHandler: A closure that handles an async sequence of updates to the value.
    /// - Returns: The result produced by the handler.
    public func watchValue<Return: ~Copyable>(
        for variable: ConfigVariable<[String]>,
        fileID: String = #fileID,
        line: UInt = #line,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<[String], Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchStringArray(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }


    /// Watches for updates to the value for the specified `[UInt8]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to watch for updates.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    ///   - updatesHandler: A closure that handles an async sequence of updates to the value.
    /// - Returns: The result produced by the handler.
    public func watchValue<Return: ~Copyable>(
        for variable: ConfigVariable<[UInt8]>,
        fileID: String = #fileID,
        line: UInt = #line,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<[UInt8], Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchBytes(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }


    /// Watches for updates to the value for the specified `[[UInt8]]` config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to watch for updates.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    ///   - updatesHandler: A closure that handles an async sequence of updates to the value.
    /// - Returns: The result produced by the handler.
    public func watchValue<Return: ~Copyable>(
        for variable: ConfigVariable<[[UInt8]]>,
        fileID: String = #fileID,
        line: UInt = #line,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<[[UInt8]], Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchByteChunkArray(
            forKey: variable.key,
            isSecret: variable.isSecret,
            default: variable.defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }
}
