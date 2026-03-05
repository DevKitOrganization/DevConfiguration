//
//  ConfigVariableReader.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 1/7/2026.
//

import Configuration
import DevFoundation

/// Provides access to configuration values queried by a `ConfigVariable`.
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


extension ConfigVariableReader {
    /// Whether the given variable is secret.
    ///
    /// The default implementation returns `true` only when the secrecy is `.secret`.
    ///
    /// - Parameter variable: The config variable whose secrecy is being determined..
    func isSecret<Value>(_ variable: ConfigVariable<Value>) -> Bool {
        return variable.secrecy == .secret
    }


    /// Whether the given `String` variable is secret, that is, not `.public`.
    ///
    /// - Parameter variable: The config variable whose secrecy is being determined..
    func isSecret(_ variable: ConfigVariable<String>) -> Bool {
        return variable.secrecy != .public
    }


    /// Whether the given `[String]` variable is secret, that is, not `.public`.
    ///
    /// - Parameter variable: The config variable whose secrecy is being determined..
    func isSecret(_ variable: ConfigVariable<[String]>) -> Bool {
        return variable.secrecy != .public
    }


    /// Whether the given `RawRepresentable<String>` variable is secret, that is, not `.public`.
    ///
    /// - Parameter variable: The config variable whose secrecy is being determined..
    func isSecret<Value>(_ variable: ConfigVariable<Value>) -> Bool where Value: RawRepresentable<String> {
        return variable.secrecy != .public
    }


    /// Whether the given `[RawRepresentable<String>]` variable is secret, that is, not `.public`.
    ///
    /// - Parameter variable: The config variable whose secrecy is being determined..
    func isSecret<Element>(_ variable: ConfigVariable<[Element]>) -> Bool where Element: RawRepresentable<String> {
        return variable.secrecy != .public
    }


    /// Whether the given `ExpressibleByConfigString` variable is secret, that is, not `.public`.
    ///
    /// - Parameter variable: The config variable whose secrecy is being determined..
    func isSecret<Value>(_ variable: ConfigVariable<Value>) -> Bool where Value: ExpressibleByConfigString {
        return variable.secrecy != .public
    }


    /// Whether the given `[ExpressibleByConfigString]` variable is secret, that is, not `.public`.
    ///
    /// - Parameter variable: The config variable whose secrecy is being determined..
    func isSecret<Element>(_ variable: ConfigVariable<[Element]>) -> Bool where Element: ExpressibleByConfigString {
        return variable.secrecy != .public
    }
}
