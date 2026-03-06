//
//  ConfigVariableContent.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/5/2026.
//

import Configuration
import DevFoundation
import Foundation

/// Describes how a ``ConfigVariable`` value maps to and from `ConfigContent` primitives.
///
/// `ConfigVariableContent` encapsulates which `ConfigReader` method to call, how to decode the raw primitive into the
/// variable’s value type, and how to encode the value back for registration. It also determines secrecy behavior based
/// on the underlying content type.
///
/// For primitive types like `Bool`, `Int`, `String`, etc., you typically don’t need to interact with this type
/// directly — ``ConfigVariable`` initializers set the appropriate content automatically. For `Codable` types, you
/// specify the content explicitly using factories like ``json(representation:decoder:encoder:)`` or
/// ``propertyList(representation:decoder:encoder:)``:
///
///     let experiment = ConfigVariable(
///         key: "experiment.onboarding",
///         defaultValue: ExperimentConfig.default,
///         content: .json()
///     )
public struct ConfigVariableContent<Value>: Sendable where Value: Sendable {
    /// Whether `.auto` secrecy treats this content type as secret.
    public let isAutoSecret: Bool

    /// Reads the value synchronously from a `ConfigReader`.
    let read:
        @Sendable (
            _ reader: ConfigReader,
            _ key: ConfigKey,
            _ isSecret: Bool,
            _ defaultValue: Value,
            _ eventBus: EventBus,
            _ fileID: String,
            _ line: UInt
        ) -> Value

    /// Fetches the value asynchronously from a `ConfigReader`.
    let fetch:
        @Sendable (
            _ reader: ConfigReader,
            _ key: ConfigKey,
            _ isSecret: Bool,
            _ defaultValue: Value,
            _ eventBus: EventBus,
            _ fileID: String,
            _ line: UInt
        ) async throws -> Value

    /// Watches for value changes, yielding decoded values to the continuation.
    let startWatching:
        @Sendable (
            _ reader: ConfigReader,
            _ key: ConfigKey,
            _ isSecret: Bool,
            _ defaultValue: Value,
            _ eventBus: EventBus,
            _ fileID: String,
            _ line: UInt,
            _ continuation: AsyncStream<Value>.Continuation
        ) async throws -> Void

    /// Encodes a value into a ``ConfigContent`` for registration.
    let encode: @Sendable (_ value: Value) throws -> ConfigContent
}


// MARK: - Primitive Content Factories

extension ConfigVariableContent where Value == Bool {
    /// Content for `Bool` values.
    public static var bool: ConfigVariableContent {
        ConfigVariableContent(
            isAutoSecret: false,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.bool(forKey: key, isSecret: isSecret, default: defaultValue, fileID: fileID, line: line)
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchBool(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchBool(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .bool($0) }
        )
    }
}


extension ConfigVariableContent where Value == [Bool] {
    /// Content for `[Bool]` values.
    public static var boolArray: ConfigVariableContent {
        ConfigVariableContent(
            isAutoSecret: false,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.boolArray(forKey: key, isSecret: isSecret, default: defaultValue, fileID: fileID, line: line)
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchBoolArray(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchBoolArray(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .boolArray($0) }
        )
    }
}


extension ConfigVariableContent where Value == Float64 {
    /// Content for `Float64` values.
    public static var float64: ConfigVariableContent {
        ConfigVariableContent(
            isAutoSecret: false,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.double(forKey: key, isSecret: isSecret, default: defaultValue, fileID: fileID, line: line)
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchDouble(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchDouble(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .double($0) }
        )
    }
}


extension ConfigVariableContent where Value == [Float64] {
    /// Content for `[Float64]` values.
    public static var float64Array: ConfigVariableContent {
        ConfigVariableContent(
            isAutoSecret: false,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.doubleArray(forKey: key, isSecret: isSecret, default: defaultValue, fileID: fileID, line: line)
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchDoubleArray(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchDoubleArray(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .doubleArray($0) }
        )
    }
}


extension ConfigVariableContent where Value == Int {
    /// Content for `Int` values.
    public static var int: ConfigVariableContent {
        ConfigVariableContent(
            isAutoSecret: false,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.int(forKey: key, isSecret: isSecret, default: defaultValue, fileID: fileID, line: line)
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchInt(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchInt(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .int($0) }
        )
    }
}


extension ConfigVariableContent where Value == [Int] {
    /// Content for `[Int]` values.
    public static var intArray: ConfigVariableContent {
        ConfigVariableContent(
            isAutoSecret: false,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.intArray(forKey: key, isSecret: isSecret, default: defaultValue, fileID: fileID, line: line)
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchIntArray(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchIntArray(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .intArray($0) }
        )
    }
}


extension ConfigVariableContent where Value == String {
    /// Content for `String` values.
    public static var string: ConfigVariableContent {
        ConfigVariableContent(
            isAutoSecret: true,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.string(forKey: key, isSecret: isSecret, default: defaultValue, fileID: fileID, line: line)
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchString(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchString(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .string($0) }
        )
    }
}


extension ConfigVariableContent where Value == [String] {
    /// Content for `[String]` values.
    public static var stringArray: ConfigVariableContent {
        ConfigVariableContent(
            isAutoSecret: true,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.stringArray(forKey: key, isSecret: isSecret, default: defaultValue, fileID: fileID, line: line)
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchStringArray(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchStringArray(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .stringArray($0) }
        )
    }
}


extension ConfigVariableContent where Value == [UInt8] {
    /// Content for `[UInt8]` (bytes) values.
    public static var bytes: ConfigVariableContent {
        ConfigVariableContent(
            isAutoSecret: false,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.bytes(forKey: key, isSecret: isSecret, default: defaultValue, fileID: fileID, line: line)
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchBytes(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchBytes(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .bytes($0) }
        )
    }
}


extension ConfigVariableContent where Value == [[UInt8]] {
    /// Content for `[[UInt8]]` (byte chunk array) values.
    public static var byteChunkArray: ConfigVariableContent {
        ConfigVariableContent(
            isAutoSecret: false,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.byteChunkArray(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchByteChunkArray(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchByteChunkArray(
                    forKey: key,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .byteChunkArray($0) }
        )
    }
}


// MARK: - String-Convertible Content Factories

extension ConfigVariableContent {
    /// Content for `RawRepresentable<String>` values.
    public static func rawRepresentableString() -> ConfigVariableContent
    where Value: RawRepresentable & Sendable, Value.RawValue == String {
        ConfigVariableContent(
            isAutoSecret: true,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.string(
                    forKey: key,
                    as: Value.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchString(
                    forKey: key,
                    as: Value.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchString(
                    forKey: key,
                    as: Value.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .string($0.rawValue) }
        )
    }


    /// Content for `[RawRepresentable<String>]` values.
    public static func rawRepresentableStringArray<Element>() -> ConfigVariableContent
    where Value == [Element], Element: RawRepresentable & Sendable, Element.RawValue == String {
        ConfigVariableContent(
            isAutoSecret: true,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.stringArray(
                    forKey: key,
                    as: Element.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchStringArray(
                    forKey: key,
                    as: Element.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchStringArray(
                    forKey: key,
                    as: Element.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .stringArray($0.map(\.rawValue)) }
        )
    }


    /// Content for `ExpressibleByConfigString` values.
    public static func expressibleByConfigString() -> ConfigVariableContent where Value: ExpressibleByConfigString {
        ConfigVariableContent(
            isAutoSecret: true,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.string(
                    forKey: key,
                    as: Value.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchString(
                    forKey: key,
                    as: Value.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchString(
                    forKey: key,
                    as: Value.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .string($0.description) }
        )
    }


    /// Content for `[ExpressibleByConfigString]` values.
    public static func expressibleByConfigStringArray<Element>() -> ConfigVariableContent
    where Value == [Element], Element: ExpressibleByConfigString & Sendable {
        ConfigVariableContent(
            isAutoSecret: true,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.stringArray(
                    forKey: key,
                    as: Element.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchStringArray(
                    forKey: key,
                    as: Element.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchStringArray(
                    forKey: key,
                    as: Element.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .stringArray($0.map(\.description)) }
        )
    }
}


// MARK: - Int-Convertible Content Factories

extension ConfigVariableContent {
    /// Content for `RawRepresentable<Int>` values.
    public static func rawRepresentableInt() -> ConfigVariableContent
    where Value: RawRepresentable & Sendable, Value.RawValue == Int {
        ConfigVariableContent(
            isAutoSecret: false,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.int(
                    forKey: key,
                    as: Value.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchInt(
                    forKey: key,
                    as: Value.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchInt(
                    forKey: key,
                    as: Value.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .int($0.rawValue) }
        )
    }


    /// Content for `[RawRepresentable<Int>]` values.
    public static func rawRepresentableIntArray<Element>() -> ConfigVariableContent
    where Value == [Element], Element: RawRepresentable & Sendable, Element.RawValue == Int {
        ConfigVariableContent(
            isAutoSecret: false,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.intArray(
                    forKey: key,
                    as: Element.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchIntArray(
                    forKey: key,
                    as: Element.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchIntArray(
                    forKey: key,
                    as: Element.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .intArray($0.map(\.rawValue)) }
        )
    }


    /// Content for `ExpressibleByConfigInt` values.
    public static func expressibleByConfigInt() -> ConfigVariableContent where Value: ExpressibleByConfigInt {
        ConfigVariableContent(
            isAutoSecret: false,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.int(
                    forKey: key,
                    as: Value.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchInt(
                    forKey: key,
                    as: Value.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchInt(
                    forKey: key,
                    as: Value.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .int($0.configInt) }
        )
    }


    /// Content for `[ExpressibleByConfigInt]` values.
    public static func expressibleByConfigIntArray<Element>() -> ConfigVariableContent
    where Value == [Element], Element: ExpressibleByConfigInt & Sendable {
        ConfigVariableContent(
            isAutoSecret: false,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                reader.intArray(
                    forKey: key,
                    as: Element.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                try await reader.fetchIntArray(
                    forKey: key,
                    as: Element.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                )
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                try await reader.watchIntArray(
                    forKey: key,
                    as: Element.self,
                    isSecret: isSecret,
                    default: defaultValue,
                    fileID: fileID,
                    line: line
                ) { updates in
                    for await value in updates {
                        continuation.yield(value)
                    }
                }
            },
            encode: { .intArray($0.map(\.configInt)) }
        )
    }
}


// MARK: - Codable Content Factories

extension ConfigVariableContent {
    /// Content for JSON-encoded `Codable` values.
    ///
    /// - Parameters:
    ///   - representation: How the JSON value is represented in the provider. Defaults to `.string()`.
    ///   - decoder: The JSON decoder to use. If `nil`, a default `JSONDecoder` is created when needed.
    ///   - encoder: The JSON encoder to use. If `nil`, a default `JSONEncoder` is created when needed.
    public static func json(
        representation: CodableValueRepresentation = .string(),
        decoder: JSONDecoder? = nil,
        encoder: JSONEncoder? = nil
    ) -> ConfigVariableContent where Value: Codable {
        codable(
            representation: representation,
            decoder: decoder as (any TopLevelDecoder<Data> & Sendable)?,
            encoder: encoder as (any TopLevelEncoder<Data> & Sendable)?
        )
    }


    /// Content for property list-encoded `Codable` values.
    ///
    /// - Parameters:
    ///   - representation: How the property list value is represented in the provider. Defaults to `.data`.
    ///   - decoder: The property list decoder to use. If `nil`, a default `PropertyListDecoder` is created when needed.
    ///   - encoder: The property list encoder to use. If `nil`, a default `PropertyListEncoder` is created when needed.
    public static func propertyList(
        representation: CodableValueRepresentation = .data,
        decoder: PropertyListDecoder? = nil,
        encoder: PropertyListEncoder? = nil
    ) -> ConfigVariableContent where Value: Codable {
        codable(
            representation: representation,
            decoder: decoder as (any TopLevelDecoder<Data> & Sendable)?,
            encoder: encoder as (any TopLevelEncoder<Data> & Sendable)?
        )
    }


    /// Creates content for a `Codable` value using the specified representation, decoder, and encoder.
    private static func codable(
        representation: CodableValueRepresentation,
        decoder: (any TopLevelDecoder<Data> & Sendable)?,
        encoder: (any TopLevelEncoder<Data> & Sendable)?
    ) -> ConfigVariableContent where Value: Codable {
        ConfigVariableContent(
            isAutoSecret: representation.isStringBacked,
            read: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                guard
                    let data = representation.readData(
                        from: reader,
                        forKey: key,
                        isSecret: isSecret,
                        fileID: fileID,
                        line: line
                    )
                else {
                    return defaultValue
                }

                let resolvedDecoder = decoder ?? JSONDecoder()
                do {
                    return try resolvedDecoder.decode(Value.self, from: data)
                } catch {
                    eventBus.post(
                        ConfigVariableDecodingFailedEvent(
                            key: AbsoluteConfigKey(key),
                            targetType: Value.self,
                            error: error
                        )
                    )
                    return defaultValue
                }
            },
            fetch: { (reader, key, isSecret, defaultValue, eventBus, fileID, line) in
                guard
                    let data = try await representation.fetchData(
                        from: reader,
                        forKey: key,
                        isSecret: isSecret,
                        fileID: fileID,
                        line: line
                    )
                else {
                    return defaultValue
                }

                let resolvedDecoder = decoder ?? JSONDecoder()
                do {
                    return try resolvedDecoder.decode(Value.self, from: data)
                } catch {
                    eventBus.post(
                        ConfigVariableDecodingFailedEvent(
                            key: AbsoluteConfigKey(key),
                            targetType: Value.self,
                            error: error
                        )
                    )
                    return defaultValue
                }
            },
            startWatching: { (reader, key, isSecret, defaultValue, eventBus, fileID, line, continuation) in
                let resolvedDecoder = decoder ?? JSONDecoder()

                try await representation.watchData(
                    from: reader,
                    forKey: key,
                    isSecret: isSecret,
                    fileID: fileID,
                    line: line
                ) { data in
                    if let data {
                        do {
                            continuation.yield(try resolvedDecoder.decode(Value.self, from: data))
                            return
                        } catch {
                            eventBus.post(
                                ConfigVariableDecodingFailedEvent(
                                    key: AbsoluteConfigKey(key),
                                    targetType: Value.self,
                                    error: error
                                )
                            )
                        }
                    }
                    continuation.yield(defaultValue)
                }
            },
            encode: { (value) in
                let resolvedEncoder = encoder ?? JSONEncoder()
                let data = try resolvedEncoder.encode(value)
                return try representation.encodeToContent(data)
            }
        )
    }
}
