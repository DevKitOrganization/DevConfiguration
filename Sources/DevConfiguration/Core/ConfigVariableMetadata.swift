//
//  ConfigVariableMetadata.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 2/16/2026.
//

import DevFoundation
import Foundation

/// A type-safe, extensible container for storing arbitrary metadata associated with configuration variables.
///
/// `ConfigVariableMetadata` provides a flexible system for attaching custom metadata to configuration variables without
/// requiring changes to the core configuration types. Metadata is accessed through type-safe keys that conform to
/// ``ConfigVariableMetadataKey``, ensuring compile-time safety while allowing unlimited extensibility.
///
/// ## Usage
///
/// Define custom metadata keys by creating types conforming to ``ConfigVariableMetadataKey`` and extending
/// `ConfigVariableMetadata` with convenience properties:
///
///     private struct ProjectMetadataKey: ConfigVariableMetadataKey {
///         static let defaultValue: String? = nil
///         static let keyDisplayText = "Project"
///     }
///
///     extension ConfigVariableMetadata {
///         var project: String? {
///             get { self[ProjectMetadataKey.self] }
///             set { self[ProjectMetadataKey.self] = newValue }
///         }
///     }
///
/// Then use the metadata with configuration variables:
///
///     var metadata = ConfigVariableMetadata()
///     metadata.project = "MyApp"
///
/// ## Thread Safety
///
/// `ConfigVariableMetadata` conforms to `Sendable`, making it safe to use across concurrency domains. All stored
/// values must also conform to `Sendable` to maintain this guarantee.
public struct ConfigVariableMetadata: Hashable, Sendable {
    /// A structure containing human-readable text representations of a metadata key-value pair.
    ///
    /// `DisplayText` pairs a metadata key's display name with the formatted string representation of its value. These
    /// representations are intended for use in user interfaces, logs, and debugging output.
    struct DisplayText: Hashable, Sendable {
        /// The human-readable display name for the metadata key (e.g., "Project", "Environment").
        let key: String

        /// The formatted string representation of the metadata value.
        ///
        /// If `nil`, the value has no canonical display representation, and a standard string should be displayed
        /// instead.
        let value: String?
    }


    /// Internal storage for metadata values, keyed by the unique identifier of each metadata key type.
    private var metadata: [ObjectIdentifier: AnySendableHashable] = [:]

    /// Internal storage for display text representations of metadata values, keyed by the unique identifier of each
    /// metadata key type.
    ///
    /// This dictionary maintains human-readable representations of stored metadata values for use in user interfaces,
    /// logs, and debugging output. Each entry maps a metadata key's `ObjectIdentifier` to a `DisplayText` structure
    /// containing both the key's display name and the formatted value.
    private var displayText: [ObjectIdentifier: DisplayText] = [:]


    /// Creates an empty metadata container with no values set.
    ///
    /// All metadata keys will return their default values until explicitly set.
    public init() {}


    /// Accesses the metadata value associated with the given key type.
    ///
    /// Returns the key's `defaultValue` if no value has been explicitly set.
    ///
    /// - Parameter key: The metadata key type that identifies which metadata value to access.
    /// - Returns: The stored value for the given key, or the key's `defaultValue` if no value has been set.
    public subscript<Key>(key: Key.Type) -> Key.Value where Key: ConfigVariableMetadataKey {
        get {
            let defaultValue = key.defaultValue
            return metadata[ObjectIdentifier(key), default: AnySendableHashable(defaultValue)].base as! Key.Value
        }
        set {
            let id = ObjectIdentifier(key)
            metadata[id] = AnySendableHashable(newValue)
            displayText[id] = .init(key: Key.keyDisplayText, value: Key.displayText(for: newValue))
        }
    }


    /// Returns an array of all display text representations for the metadata values currently stored in this container.
    ///
    /// This property provides access to human-readable key-value pairs representing all metadata that has been
    /// explicitly set. Each `DisplayText` entry contains both the metadata key's display name and the formatted value.
    ///
    /// The returned array is unordered and includes only metadata that has been assigned through the subscript setter.
    /// Metadata keys that still have their default values are not included in the results.
    ///
    /// - Returns: An array of `DisplayText` structures representing all stored metadata entries.
    var displayTextEntries: [DisplayText] {
        return Array(displayText.values)
    }
}


// MARK: - ConfigVariableMetadataKey

/// A type that defines a key for storing and retrieving metadata associated with configuration variables.
///
/// Use this protocol to create custom metadata keys that can be used with ``ConfigVariableMetadata``. Each conforming
/// type acts as a unique key for a specific piece of metadata, providing type-safe access through the subscript on
/// `ConfigVariableMetadata`.
///
/// ## Creating a Custom Metadata Key
///
/// To define a new metadata key, create a private type that conforms to `ConfigVariableMetadataKey` and implement the
/// required properties:
///
///     private struct projectMetadataKey: ConfigVariableMetadataKey {
///         static let defaultValue: String? = nil
///         static let keyDisplayText: String = "Project"
///     }
///
/// Then extend `ConfigVariableMetadata` with a convenience property to access the value:
///
///     extension ConfigVariableMetadata {
///         var project: String? {
///             get { self[ProjectMetadataKey.self] }
///             set { self[ProjectMetadataKey.self] = newValue }
///         }
///     }
///
/// ## Default Implementations
///
/// DevConfiguration provides default implementations of ``displayText(for:)`` for common value types:
///
///   - Generic values use `String(describing:)`
///   - `RawRepresentable<String>` values use their `rawValue`
///   - `Optional` values unwrap and describe the wrapped value
public protocol ConfigVariableMetadataKey {
    /// The type of value stored for this metadata key.
    ///
    /// The value type must conform to `Hashable` for equality comparisons and `Sendable` for safe concurrent access.
    associatedtype Value: Hashable & Sendable

    /// The default value returned when no value has been explicitly set for this metadata key.
    ///
    /// This value is used by ``ConfigVariableMetadata``'s subscript when retrieving a value for a key that has not
    /// been assigned. For optional metadata, this is typically `nil`. For required metadata, provide a sensible
    /// default that represents the absence of explicit configuration.
    static var defaultValue: Value { get }

    /// A human-readable label for this metadata key, used when displaying metadata in user interfaces or logs.
    ///
    /// This text should be localized when appropriate and should clearly describe what the metadata represents.
    /// For example, a key that stores a project name might return `"Project"`.
    static var keyDisplayText: String { get }

    /// Returns a human-readable string representation of the given metadata value for display purposes.
    ///
    /// This function is used to convert metadata values into text suitable for display in user interfaces, logs, or
    /// debugging output. The returned string should be localized when appropriate and provide a clear, concise
    /// representation of the value.
    ///
    /// DevConfiguration provides default implementations for common types:
    ///
    ///   - For general values, returns `String(describing:)`
    ///   - For `RawRepresentable<String>` values, returns the `rawValue`
    ///   - For `Optional` values, returns `nil` when the value is `nil`, or a description of the unwrapped value
    ///
    /// ## Custom Implementations
    ///
    /// Provide your own implementation when you need custom formatting for your metadata values. For example, if your
    /// value is a `Date`, you might return a formatted version of it:
    ///
    ///     static func displayText(for date: Date) -> String? {
    ///         return date.formatted(date: .long, time: .omitted)
    ///     }
    ///
    /// - Note: `ConfigVariableMetadata` only gets display text when a value is set. As such, the display text for a
    ///   given value should not change over time. For example, when formatting a date, don’t use relative formatting,
    ///   as the time between when the display text is computed and displayed may be significant.
    ///
    /// - Parameter value: The metadata value to convert to a display string.
    /// - Returns: A human-readable string representation of the value, or `nil` if the value should not be displayed
    ///   (such as when an optional value is `nil`).
    static func displayText(for value: Value) -> String?
}


// MARK: - Default Implementations

extension ConfigVariableMetadataKey {
    public static func displayText(for value: Value) -> String? {
        return String(describing: value)
    }
}


extension ConfigVariableMetadataKey where Value: RawRepresentable<String> {
    public static func displayText(for value: Value) -> String? {
        return value.rawValue
    }
}


extension ConfigVariableMetadataKey where Value: OptionalRepresentable {
    public static func displayText(for value: Value) -> String? {
        return value.optionalRepresentation.map { String(describing: $0) }
    }
}


extension ConfigVariableMetadataKey where Value: OptionalRepresentable, Value.Wrapped: RawRepresentable<String> {
    public static func displayText(for value: Value) -> String? {
        return value.optionalRepresentation.map { $0.rawValue }
    }
}
