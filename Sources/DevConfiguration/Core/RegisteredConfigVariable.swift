//
//  RegisteredConfigVariable.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/5/2026.
//

import Configuration
import Foundation

/// A non-generic representation of a registered ``ConfigVariable``.
///
/// `RegisteredConfigVariable` stores the type-erased information from a ``ConfigVariable`` so that registered variables
/// can be stored in homogeneous collections. It captures the variable's key, its default value as a ``ConfigContent``,
/// its secrecy setting, and any attached metadata.
@dynamicMemberLookup
public struct RegisteredConfigVariable: Sendable {
    /// The configuration key used to look up this variable's value.
    public let key: ConfigKey

    /// The variable's default value represented as a ``ConfigContent``.
    public let defaultContent: ConfigContent

    /// Whether this variable's value should be treated as secret.
    public let isSecret: Bool

    /// The configuration variable's metadata.
    public let metadata: ConfigVariableMetadata

    /// The name of the variable's Swift value type (e.g., `"Int"`, `"CardSuit"`).
    ///
    /// This is captured at registration time via `String(describing: Value.self)` and may differ from the content type
    /// name when the variable uses a type that maps to a primitive content type (e.g., an `Int`-backed enum stored as
    /// ``ConfigContent/int(_:)``). Standard generic types are normalized to use Swift shorthand syntax (e.g.,
    /// `Array<Int>` becomes `[Int]`, `Optional<String>` becomes `String?`, and `Dictionary<String, Int>` becomes
    /// `[String: Int]`).
    public let destinationTypeName: String

    /// A human-readable name for this variable's content type (e.g., `"Bool"`, `"[Int]"`).
    ///
    /// This is derived from the variable's ``defaultContent`` and represents the primitive configuration type used for
    /// storage, which may differ from ``destinationTypeName``.
    public var contentTypeName: String {
        defaultContent.typeDisplayName
    }

    /// The editor control to use when editing this variable's value in the editor UI.
    public let editorControl: EditorControl

    /// Parses a raw string from the editor UI into a ``ConfigContent`` value.
    ///
    /// Returns `nil` if the string cannot be parsed. When this property itself is `nil`, the variable does not support
    /// editing.
    let parse: (@Sendable (_ input: String) -> ConfigContent?)?


    /// Creates a new registered config variable.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - defaultContent: The default value as a ``ConfigContent``.
    ///   - isSecret: Whether the variable's value should be treated as secret.
    ///   - metadata: The variable's metadata.
    ///   - destinationTypeName: The name of the variable's Swift value type.
    ///   - editorControl: The editor control to use for this variable.
    ///   - parse: A function that parses a raw string into a ``ConfigContent`` value.
    init(
        key: ConfigKey,
        defaultContent: ConfigContent,
        isSecret: Bool,
        metadata: ConfigVariableMetadata,
        destinationTypeName: String,
        editorControl: EditorControl,
        parse: (@Sendable (_ input: String) -> ConfigContent?)?
    ) {
        self.key = key
        self.defaultContent = defaultContent
        self.isSecret = isSecret
        self.metadata = metadata
        self.destinationTypeName = Self.normalizedTypeName(destinationTypeName)
        self.editorControl = editorControl
        self.parse = parse
    }


    /// Provides dynamic member lookup access to metadata properties.
    ///
    /// This subscript enables dot-syntax access to metadata properties, mirroring the access pattern on
    /// ``ConfigVariable``.
    ///
    /// - Parameter keyPath: A keypath to a property on `ConfigVariableMetadata`.
    /// - Returns: The value of the metadata property.
    subscript<MetadataValue>(
        dynamicMember keyPath: KeyPath<ConfigVariableMetadata, MetadataValue>
    ) -> MetadataValue {
        metadata[keyPath: keyPath]
    }


    /// Normalizes a Swift type name to use shorthand syntax for standard generic types.
    ///
    /// Converts `Array<X>` to `[X]`, `Optional<X>` to `X?`, `Dictionary<K, V>` to `[K: V]`, and `Double` to `Float64`.
    private static func normalizedTypeName(_ name: String) -> String {
        var result = name.replacing(/\bDouble\b/, with: "Float64")
        // Normalize Array<...> to [...]
        while let range = result.range(of: "Array<") {
            let openIndex = range.upperBound
            guard let closeIndex = findMatchingClosingAngleBracket(in: result, from: openIndex) else {
                break
            }
            let inner = result[openIndex ..< closeIndex]
            let prefix = result[result.startIndex ..< range.lowerBound]
            let suffix = result[result.index(after: closeIndex)...]
            result = prefix + "[\(inner)]" + suffix
        }

        // Normalize Dictionary<K, V> to [K: V]
        while let range = result.range(of: "Dictionary<") {
            let openIndex = range.upperBound
            guard let closeIndex = findMatchingClosingAngleBracket(in: result, from: openIndex) else {
                break
            }
            let inner = result[openIndex ..< closeIndex]
            // Split on the first top-level comma
            guard let commaIndex = findTopLevelComma(in: inner) else {
                break
            }
            let key = inner[inner.startIndex ..< commaIndex]
            let value = inner[inner.index(after: commaIndex)...].drop(while: { $0 == " " })
            result =
                result[result.startIndex ..< range.lowerBound] + "[\(key): \(value)]"
                + result[result.index(after: closeIndex)...]
        }

        // Normalize Optional<...> to ...?
        while let range = result.range(of: "Optional<") {
            let openIndex = range.upperBound
            guard let closeIndex = findMatchingClosingAngleBracket(in: result, from: openIndex) else {
                break
            }
            let inner = result[openIndex ..< closeIndex]
            result =
                result[result.startIndex ..< range.lowerBound] + "\(inner)?"
                + result[result.index(after: closeIndex)...]
        }

        return result
    }


    /// Finds the index of the closing `>` that matches the opening `<` whose content starts at `startIndex`.
    private static func findMatchingClosingAngleBracket(
        in string: String,
        from startIndex: String.Index
    ) -> String.Index? {
        var depth = 1
        var index = startIndex
        while index < string.endIndex {
            switch string[index] {
            case "<": depth += 1
            case ">":
                depth -= 1
                if depth == 0 { return index }
            default: break
            }
            index = string.index(after: index)
        }
        return nil
    }


    /// Finds the index of the first comma at the top level (depth 0) within a substring.
    private static func findTopLevelComma(in string: some StringProtocol) -> String.Index? {
        var depth = 0
        for index in string.indices {
            switch string[index] {
            case "<":
                depth += 1
            case ">":
                depth -= 1
            case "," where depth == 0:
                return index
            default: break
            }
        }
        return nil
    }
}
