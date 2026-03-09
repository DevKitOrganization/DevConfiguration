//
//  ConfigVariableReader.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 1/7/2026.
//

import Configuration
import DevFoundation
import OSLog
import Synchronization

/// Provides access to configuration values queried by a `ConfigVariable`.
///
/// A config variable reader is a type-safe wrapper around swift-configuration’s `ConfigReader`. It uses
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
///         namedProviders: [
///             .init(InMemoryProvider(values: ["dark_mode": "true"]), displayName: "In-Memory")
///         ],
///         eventBus: eventBus
///     )
///
///     let darkMode = reader[.darkMode]  // true
///
/// The reader never throws. If resolution fails, it returns the variable’s default value and posts a
/// ``ConfigVariableAccessFailedEvent`` to the event bus.
public final class ConfigVariableReader: Sendable {
    /// The mutable state of a ``ConfigVariableReader``, protected by a `Mutex`.
    private struct MutableState: Sendable {
        /// The variables that have been registered with the reader, keyed by their configuration key.
        var registeredVariables: [ConfigKey: RegisteredConfigVariable] = [:]
    }


    /// The access reporter that is used to report configuration access events.
    public let accessReporter: any AccessReporter

    /// The configuration reader that is used to resolve configuration values.
    public let reader: ConfigReader

    /// The configuration reader’s named providers.
    ///
    /// When editor support is enabled, the editor override provider is the first entry.
    public let namedProviders: [NamedConfigProvider]

    /// The event bus used to post diagnostic events like ``ConfigVariableDecodingFailedEvent``.
    public let eventBus: EventBus

    /// The editor override provider, if editor support is enabled.
    ///
    /// When non-nil, this provider is the first entry in ``namedProviders`` and takes precedence over all other
    /// providers.
    let editorOverrideProvider: EditorOverrideProvider?

    /// The mutable state protected by a mutex.
    private let mutableState = Mutex(MutableState())

    /// The logger used for registration diagnostics.
    private static let logger = Logger(subsystem: "DevConfiguration", category: "ConfigVariableReader")


    /// Creates a new `ConfigVariableReader` with the specified providers and the default telemetry access reporter.
    ///
    /// Use this initializer when you want to use the standard `EventBusAccessReporter`.
    ///
    /// - Parameters:
    ///   - namedProviders: The named configuration providers, queried in order until a value is found.
    ///   - eventBus: The event bus that telemetry events are posted on.
    ///   - isEditorEnabled: Whether editor override support is enabled. Defaults to `false`.
    public convenience init(
        namedProviders: [NamedConfigProvider],
        eventBus: EventBus,
        isEditorEnabled: Bool = false
    ) {
        self.init(
            namedProviders: namedProviders,
            accessReporter: EventBusAccessReporter(eventBus: eventBus),
            eventBus: eventBus,
            isEditorEnabled: isEditorEnabled
        )
    }


    /// Creates a new `ConfigVariableReader` with the specified providers, access reporter, and event bus.
    ///
    /// Use this initializer when you want to directly control the access reporter used by the config reader.
    ///
    /// - Parameters:
    ///   - namedProviders: The named configuration providers, queried in order until a value is found.
    ///   - accessReporter: The access reporter that is used to report configuration access events.
    ///   - eventBus: The event bus used to post diagnostic events.
    ///   - isEditorEnabled: Whether editor override support is enabled. Defaults to `false`.
    public init(
        namedProviders: [NamedConfigProvider],
        accessReporter: any AccessReporter,
        eventBus: EventBus,
        isEditorEnabled: Bool = false
    ) {
        var editorOverrideProvider: EditorOverrideProvider?
        var namedProviders = namedProviders

        if isEditorEnabled {
            let provider = EditorOverrideProvider()
            provider.load(from: UserDefaults(suiteName: EditorOverrideProvider.suiteName)!)
            editorOverrideProvider = provider
            namedProviders.insert(.init(provider, displayName: localizedString("editorOverrideProvider.name")), at: 0)
        }

        self.editorOverrideProvider = editorOverrideProvider
        self.accessReporter = accessReporter
        self.reader = ConfigReader(
            providers: namedProviders.map(\.provider),
            accessReporter: accessReporter
        )
        self.namedProviders = namedProviders
        self.eventBus = eventBus
    }


    /// The variables that have been registered with this reader, keyed by their configuration key.
    var registeredVariables: [ConfigKey: RegisteredConfigVariable] {
        mutableState.withLock { $0.registeredVariables }
    }
}


// MARK: - Registration

extension ConfigVariableReader {
    /// Registers a configuration variable with this reader.
    ///
    /// Registration records the variable's key, default value, secrecy, and metadata in a non-generic form so that the
    /// reader can provide information about all registered variables without needing their generic type parameters.
    ///
    /// Registration is intended to be performed during setup, before the reader is shared with other components. If a
    /// variable with the same key has already been registered, the new registration overwrites the previous one, a
    /// warning is logged, and an assertion failure is triggered.
    ///
    /// - Parameter variable: The configuration variable to register.
    public func register<Value>(_ variable: ConfigVariable<Value>) {
        let defaultContent: ConfigContent
        do {
            defaultContent = try variable.content.encode(variable.defaultValue)
        } catch {
            assertionFailure("Failed to encode default value for config variable '\(variable.key)': \(error)")
            Self.logger.error("Failed to encode default value for config variable '\(variable.key)': \(error)")
            return
        }

        mutableState.withLock { state in
            if state.registeredVariables[variable.key] != nil {
                assertionFailure("Config variable '\(variable.key)' is already registered")
                Self.logger.error("Config variable '\(variable.key)' is already registered; overwriting")
            }

            state.registeredVariables[variable.key] = RegisteredConfigVariable(
                key: variable.key,
                defaultContent: defaultContent,
                isSecret: variable.isSecret,
                metadata: variable.metadata,
                destinationTypeName: String(describing: Value.self),
                editorControl: variable.content.editorControl,
                parse: variable.content.parse
            )
        }
    }
}


// MARK: - Value Access

extension ConfigVariableReader {
    /// Gets the value for the specified config variable.
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
    ) -> Value {
        variable.content.read(reader, variable.key, variable.isSecret, variable.defaultValue, eventBus, fileID, line)
    }


    /// Gets the value for the specified config variable.
    ///
    /// - Parameters:
    ///   - variable: The variable to get a value for.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The configuration value of the variable, or the default value if resolution fails.
    public subscript<Value>(
        variable: ConfigVariable<Value>,
        fileID fileID: String = #fileID,
        line line: UInt = #line
    ) -> Value {
        value(for: variable, fileID: fileID, line: line)
    }


    /// Fetches the value for the specified config variable asynchronously.
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
    ) async throws -> Value {
        try await variable.content.fetch(
            reader,
            variable.key,
            variable.isSecret,
            variable.defaultValue,
            eventBus,
            fileID,
            line
        )
    }


    /// Watches a config variable for value changes.
    ///
    /// The `updatesHandler` receives an `AsyncStream` of the variable’s decoded values, which yields a new element each
    /// time the underlying configuration value changes. The return value of the handler is returned by this method.
    ///
    /// - Parameters:
    ///   - variable: The variable to watch.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    ///   - updatesHandler: A closure that receives a stream of updated values.
    /// - Returns: The value returned by the `updatesHandler`.
    public func watchValue<Value, Return>(
        for variable: ConfigVariable<Value>,
        fileID: String = #fileID,
        line: UInt = #line,
        updatesHandler: @Sendable @escaping (AsyncStream<Value>) async throws -> Return
    ) async throws -> Return where Return: Sendable {
        // Capture these locally so that the @Sendable task closures below don’t need to capture `self`.
        let configReader = reader
        let eventBus = eventBus
        let isSecret = variable.isSecret
        let (stream, continuation) = AsyncStream<Value>.makeStream()

        // We use a task group with two concurrent tasks: one that watches the underlying provider for changes and
        // yields decoded values into the stream, and one that passes the stream to the caller’s handler. The group’s
        // element type is `Return?` so the watcher task can return `nil` while the handler task returns the caller’s
        // result.
        return try await withThrowingTaskGroup(of: Return?.self) { (group) in
            // Task 1: Watch the provider for changes. Each time the raw value changes, the content’s startWatching
            // closure decodes it and yields the result into the continuation. When watching ends (due to cancellation
            // or the provider stopping), we finish the continuation so the handler’s stream terminates.
            group.addTask {
                defer { continuation.finish() }
                try await variable.content.startWatching(
                    configReader,
                    variable.key,
                    isSecret,
                    variable.defaultValue,
                    eventBus,
                    fileID,
                    line,
                    continuation
                )
                return nil
            }

            // Task 2: Run the caller’s handler with the decoded value stream.
            group.addTask {
                return try await updatesHandler(stream)
            }

            // Wait for the first non-nil result, which will be from the handler task. Once the handler returns,
            // cancel the watcher task so the provider stops being observed.
            for try await result in group {
                if let result {
                    group.cancelAll()
                    return result
                }
            }

            // The handler task always returns a non-nil value, so we should never reach this point.
            fatalError()
        }
    }
}
