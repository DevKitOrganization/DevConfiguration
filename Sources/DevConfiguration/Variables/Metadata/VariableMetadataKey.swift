//
//  VariableMetadataKey.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 7/12/25.
//

import Foundation

/// A key for accessing metadata in a configuration variable.
public protocol VariableMetadataKey {
    /// The concrete type of the metadata value.
    associatedtype Value: Hashable & Sendable

    /// The key's default value.
    static var defaultValue: Value { get }

    /// A string representation of the key to use for display purposes.
    static var keyDisplayText: String { get }

    /// A string representation for a given value of the key for display purposes.
    ///
    /// - Parameter value: A value to build display text for.
    /// - Returns: The display text for the given value. If `nil`, a default string will be displayed.
    static func displayText(for value: Value) -> String?
}


// MARK: - Helper Protocol for Optional Types

/// A protocol for types that can represent optional values.
public protocol OptionalRepresentable {
    /// The wrapped type when the value is not nil.
    associatedtype Wrapped

    /// The optional representation of the value.
    var optionalRepresentation: Wrapped? { get }
}


extension Optional: OptionalRepresentable {
    public var optionalRepresentation: Wrapped? {
        return self
    }
}


// MARK: - Default Implementations

extension VariableMetadataKey where Value: RawRepresentable<String> {
    /// Returns the value's raw value.
    public static func displayText(for value: Value) -> String? {
        return value.rawValue
    }
}


extension VariableMetadataKey where Value: OptionalRepresentable {
    /// Returns `String(describing: value)`, or `nil` if the value is `nil`.
    public static func displayText(for value: Value) -> String? {
        return value.optionalRepresentation.map { String(describing: $0) }
    }
}


extension VariableMetadataKey where Value: OptionalRepresentable, Value.Wrapped: RawRepresentable<String> {
    /// Returns the value's raw value, or `nil` if the value is `nil`.
    public static func displayText(for value: Value) -> String? {
        return value.optionalRepresentation.map { $0.rawValue }
    }
}


extension VariableMetadataKey {
    /// Returns `String(describing: value)`.
    public static func displayText(for value: Value) -> String? {
        return String(describing: value)
    }
}
