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
/// variable’s value type, and how to encode the value back for registration.
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

    /// The editor control to use when editing this variable's value in the editor UI.
    public let editorControl: EditorControl?

    /// Parses a raw string from the editor UI into a ``ConfigContent`` value.
    ///
    /// Returns `nil` if the string cannot be parsed into a valid value for this content type. When `nil` itself, the
    /// content type does not support editing.
    let parse: (@Sendable (_ input: String) -> ConfigContent?)?

    /// Validates that a ``ConfigContent`` value can be decoded into a valid instance of the variable's destination type.
    ///
    /// For primitive types where a successful parse guarantees a valid value, this is `nil`. For types like
    /// `RawRepresentable` enums or `Codable` values, this checks that the content actually maps to a valid instance of
    /// the destination type.
    let validate: (@Sendable (_ content: ConfigContent) -> Bool)?
}


// MARK: - Primitive Content Factories

extension ConfigVariableContent where Value == Bool {
    /// Content for `Bool` values.
    public static var bool: ConfigVariableContent {
        ConfigVariableContent(
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
            encode: { .bool($0) },
            editorControl: .toggle,
            parse: { Bool($0).map { .bool($0) } },
            validate: nil
        )
    }
}


extension ConfigVariableContent where Value == [Bool] {
    /// Content for `[Bool]` values.
    public static var boolArray: ConfigVariableContent {
        ConfigVariableContent(
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
            encode: { .boolArray($0) },
            editorControl: .textEditor,
            parse: { input in
                let lines = input.nonEmptyTrimmedLines
                var values: [Bool] = []
                for line in lines {
                    guard let value = Bool(line) else {
                        return nil
                    }
                    values.append(value)
                }
                return .boolArray(values)
            },
            validate: nil
        )
    }
}


extension ConfigVariableContent where Value == Float64 {
    /// Content for `Float64` values.
    public static var float64: ConfigVariableContent {
        ConfigVariableContent(
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
            encode: { .double($0) },
            editorControl: .decimalField,
            parse: { (try? Float64($0, format: .number, lenient: false)).map { .double($0) } },
            validate: nil
        )
    }
}


extension ConfigVariableContent where Value == [Float64] {
    /// Content for `[Float64]` values.
    public static var float64Array: ConfigVariableContent {
        ConfigVariableContent(
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
            encode: { .doubleArray($0) },
            editorControl: .textEditor,
            parse: { input in
                let lines = input.nonEmptyTrimmedLines
                var values: [Float64] = []
                for line in lines {
                    guard let value = try? Float64(line, format: .number) else {
                        return nil
                    }
                    values.append(value)
                }
                return .doubleArray(values)
            },
            validate: nil
        )
    }
}


extension ConfigVariableContent where Value == Int {
    /// Content for `Int` values.
    public static var int: ConfigVariableContent {
        ConfigVariableContent(
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
            encode: { .int($0) },
            editorControl: .numberField,
            parse: {
                guard
                    let value = try? Float64($0, format: .number),
                    let int = Int(exactly: value)
                else {
                    return nil
                }
                return .int(int)
            },
            validate: nil
        )
    }
}


extension ConfigVariableContent where Value == [Int] {
    /// Content for `[Int]` values.
    public static var intArray: ConfigVariableContent {
        ConfigVariableContent(
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
            encode: { .intArray($0) },
            editorControl: .textEditor,
            parse: { input in
                let lines = input.nonEmptyTrimmedLines
                var values: [Int] = []
                for line in lines {
                    guard
                        let parsed = try? Float64(line, format: .number),
                        let value = Int(exactly: parsed)
                    else {
                        return nil
                    }
                    values.append(value)
                }
                return .intArray(values)
            },
            validate: nil
        )
    }
}


extension ConfigVariableContent where Value == String {
    /// Content for `String` values.
    public static var string: ConfigVariableContent {
        ConfigVariableContent(
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
            encode: { .string($0) },
            editorControl: .textField,
            parse: { .string($0) },
            validate: nil
        )
    }
}


extension ConfigVariableContent where Value == [String] {
    /// Content for `[String]` values.
    public static var stringArray: ConfigVariableContent {
        ConfigVariableContent(
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
            encode: { .stringArray($0) },
            editorControl: .textEditor,
            parse: { .stringArray($0.nonEmptyTrimmedLines) },
            validate: nil
        )
    }
}


extension ConfigVariableContent where Value == [UInt8] {
    /// Content for `[UInt8]` (bytes) values.
    public static var bytes: ConfigVariableContent {
        ConfigVariableContent(
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
            encode: { .bytes($0) },
            editorControl: nil,
            parse: nil,
            validate: nil
        )
    }
}


extension ConfigVariableContent where Value == [[UInt8]] {
    /// Content for `[[UInt8]]` (byte chunk array) values.
    public static var byteChunkArray: ConfigVariableContent {
        ConfigVariableContent(
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
            encode: { .byteChunkArray($0) },
            editorControl: nil,
            parse: nil,
            validate: nil
        )
    }
}


// MARK: - String-Convertible Content Factories

extension ConfigVariableContent {
    /// Content for `RawRepresentable<String>` values.
    public static func rawRepresentableString() -> ConfigVariableContent
    where Value: RawRepresentable & Sendable, Value.RawValue == String {
        ConfigVariableContent(
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
            encode: { .string($0.rawValue) },
            editorControl: .textField,
            parse: { .string($0) },
            validate: { content in
                guard case .string(let rawValue) = content else {
                    return false
                }
                return Value(rawValue: rawValue) != nil
            }
        )
    }


    /// Content for `RawRepresentable<String> & CaseIterable` values.
    ///
    /// Uses a picker control populated with all cases instead of a free-text field.
    public static func rawRepresentableCaseIterableString() -> ConfigVariableContent
    where Value: RawRepresentable & CaseIterable & Sendable, Value.RawValue == String {
        ConfigVariableContent(
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
            encode: { .string($0.rawValue) },
            editorControl: .picker(
                options: Value.allCases.map {
                    .init(
                        label: $0.rawValue,
                        content: .string($0.rawValue)
                    )
                }
            ),
            parse: nil,
            validate: nil
        )
    }


    /// Content for `[RawRepresentable<String>]` values.
    public static func rawRepresentableStringArray<Element>() -> ConfigVariableContent
    where Value == [Element], Element: RawRepresentable & Sendable, Element.RawValue == String {
        ConfigVariableContent(
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
            encode: { .stringArray($0.map(\.rawValue)) },
            editorControl: .textEditor,
            parse: { .stringArray($0.nonEmptyTrimmedLines) },
            validate: { content in
                guard case .stringArray(let strings) = content else {
                    return false
                }
                return strings.allSatisfy { Element(rawValue: $0) != nil }
            }
        )
    }


    /// Content for `ExpressibleByConfigString` values.
    public static func expressibleByConfigString() -> ConfigVariableContent where Value: ExpressibleByConfigString {
        ConfigVariableContent(
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
            encode: { .string($0.description) },
            editorControl: .textField,
            parse: { .string($0) },
            validate: { content in
                guard case .string(let string) = content else {
                    return false
                }
                return Value(configString: string) != nil
            }
        )
    }


    /// Content for `[ExpressibleByConfigString]` values.
    public static func expressibleByConfigStringArray<Element>() -> ConfigVariableContent
    where Value == [Element], Element: ExpressibleByConfigString & Sendable {
        ConfigVariableContent(
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
            encode: { .stringArray($0.map(\.description)) },
            editorControl: .textEditor,
            parse: { .stringArray($0.nonEmptyTrimmedLines) },
            validate: { content in
                guard case .stringArray(let strings) = content else {
                    return false
                }
                return strings.allSatisfy { Element(configString: $0) != nil }
            }
        )
    }
}


// MARK: - Int-Convertible Content Factories

extension ConfigVariableContent {
    /// Content for `RawRepresentable<Int>` values.
    public static func rawRepresentableInt() -> ConfigVariableContent
    where Value: RawRepresentable & Sendable, Value.RawValue == Int {
        ConfigVariableContent(
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
            encode: { .int($0.rawValue) },
            editorControl: .numberField,
            parse: {
                guard
                    let value = try? Float64($0, format: .number),
                    let int = Int(exactly: value)
                else {
                    return nil
                }
                return .int(int)
            },
            validate: { content in
                guard case .int(let rawValue) = content else {
                    return false
                }
                return Value(rawValue: rawValue) != nil
            }
        )
    }


    /// Content for `RawRepresentable<Int> & CaseIterable` values.
    ///
    /// Uses a picker control populated with all cases instead of a free-text number field.
    public static func rawRepresentableCaseIterableInt() -> ConfigVariableContent
    where Value: RawRepresentable & CaseIterable & Sendable, Value.RawValue == Int {
        ConfigVariableContent(
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
            encode: { .int($0.rawValue) },
            editorControl: .picker(
                options: Value.allCases.map { (value) in
                    .init(
                        label: "\(String(describing: value)) (\(value.rawValue))",
                        content: .int(value.rawValue)
                    )
                }
            ),
            parse: nil,
            validate: nil
        )
    }


    /// Content for `[RawRepresentable<Int>]` values.
    public static func rawRepresentableIntArray<Element>() -> ConfigVariableContent
    where Value == [Element], Element: RawRepresentable & Sendable, Element.RawValue == Int {
        ConfigVariableContent(
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
            encode: { .intArray($0.map(\.rawValue)) },
            editorControl: .textEditor,
            parse: { input in
                let lines = input.nonEmptyTrimmedLines
                var values: [Int] = []
                for line in lines {
                    guard
                        let parsed = try? Float64(line, format: .number),
                        let value = Int(exactly: parsed)
                    else {
                        return nil
                    }
                    values.append(value)
                }
                return .intArray(values)
            },
            validate: { content in
                guard case .intArray(let ints) = content else {
                    return false
                }
                return ints.allSatisfy { Element(rawValue: $0) != nil }
            }
        )
    }


    /// Content for `ExpressibleByConfigInt` values.
    public static func expressibleByConfigInt() -> ConfigVariableContent where Value: ExpressibleByConfigInt {
        ConfigVariableContent(
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
            encode: { .int($0.configInt) },
            editorControl: .numberField,
            parse: {
                guard
                    let value = try? Float64($0, format: .number),
                    let int = Int(exactly: value)
                else {
                    return nil
                }
                return .int(int)
            },
            validate: { content in
                guard case .int(let int) = content else {
                    return false
                }
                return Value(configInt: int) != nil
            }
        )
    }


    /// Content for `[ExpressibleByConfigInt]` values.
    public static func expressibleByConfigIntArray<Element>() -> ConfigVariableContent
    where Value == [Element], Element: ExpressibleByConfigInt & Sendable {
        ConfigVariableContent(
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
            encode: { .intArray($0.map(\.configInt)) },
            editorControl: .textEditor,
            parse: { input in
                let lines = input.nonEmptyTrimmedLines
                var values: [Int] = []
                for line in lines {
                    guard
                        let parsed = try? Float64(line, format: .number),
                        let value = Int(exactly: parsed)
                    else {
                        return nil
                    }
                    values.append(value)
                }
                return .intArray(values)
            },
            validate: { content in
                guard case .intArray(let ints) = content else {
                    return false
                }
                return ints.allSatisfy { Element(configInt: $0) != nil }
            }
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
        return codable(
            representation: representation,
            decoder: decoder as (any TopLevelDecoder<Data> & Sendable)?,
            encoder: encoder as (any TopLevelEncoder<Data> & Sendable)?,
            editorControl: representation.supportsTextEditing ? .textEditor : nil,
            parse: representation.supportsTextEditing ? { @Sendable in ConfigContent.string($0) } : nil
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
            encoder: encoder as (any TopLevelEncoder<Data> & Sendable)?,
            editorControl: nil,
            parse: nil
        )
    }


    /// Creates content for a `Codable` value using the specified representation, decoder, and encoder.
    private static func codable(
        representation: CodableValueRepresentation,
        decoder: (any TopLevelDecoder<Data> & Sendable)?,
        encoder: (any TopLevelEncoder<Data> & Sendable)?,
        editorControl: EditorControl?,
        parse: (@Sendable (_ input: String) -> ConfigContent?)?
    ) -> ConfigVariableContent where Value: Codable {
        ConfigVariableContent(
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
                let resolvedEncoder = encoder ?? JSONEncoder.sortedKeys
                let data = try resolvedEncoder.encode(value)
                return try representation.encodeToContent(data)
            },
            editorControl: editorControl,
            parse: parse,
            validate: { content in
                let resolvedDecoder = decoder ?? JSONDecoder()
                guard let data = representation.data(from: content) else {
                    return false
                }
                return (try? resolvedDecoder.decode(Value.self, from: data)) != nil
            }
        )
    }
}


extension JSONEncoder {
    static var sortedKeys: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }
}
