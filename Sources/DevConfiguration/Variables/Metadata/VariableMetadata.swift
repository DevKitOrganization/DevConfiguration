//
//  VariableMetadata.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 7/12/25.
//

import Foundation

/// A collection of variable metadata values that can be set and accessed from configuration
/// variable.
///
/// Use the subscript function to build a simple interface to store and retrieve values for
/// your metadata key. For example:
///
///     private struct ExpirationDateMetadataKey: VariableMetadataKey { … }
///
///     extension VariableMetadata {
///         var expirationDate: Date {
///             get { self[ExpirationDateMetadataKey.self] }
///             set { self[ExpirationDateMetadataKey.self] = newValue }
///         }
///     }
///
public struct VariableMetadata: Hashable, Sendable {
    /// A wrapper in which a Hashable Sendable value can be stored.
    struct HashableSendableWrapper: Hashable, Sendable {
        /// The Hashable Sendable value.
        nonisolated(unsafe) let value: AnyHashable


        /// Creates a new Hashable Sendable wrapper around the specified value.
        ///
        /// - Parameter value: The Hashable Sendable value to wrap.
        init<Value>(_ value: Value) where Value: Hashable & Sendable {
            self.value = value
        }
    }


    /// A display text entry for a metadata value.
    struct DisplayText: Hashable, Sendable {
        /// The display text for the metadata's key.
        public let key: String

        /// The display text for the metadata's value.
        ///
        /// A `nil` value implies that there is no display text and that a standard string should be displayed.
        public let value: String?


        /// Creates a new display text entry.
        public init(key: String, value: String?) {
            self.key = key
            self.value = value
        }
    }


    /// The underlying dictionary in which we store the metadata.
    ///
    /// The dictionary's key is the `ObjectIdentifier` for the `VariableMetadataKey`'s type.
    /// The value is a `HashableSendableWrapper` whose actual type is `VariableMetadataKey.Value`.
    private var metadata: [ObjectIdentifier: HashableSendableWrapper] = [:]

    /// A dictionary of stored display text for each key.
    ///
    /// The dictionary's key is the `ObjectIdentifier` for the `VariableMetadataKey`'s type.
    /// The value is the `DisplayText` for the key and the value, calculated at the time that the value was set.
    private var displayText: [ObjectIdentifier: DisplayText] = [:]


    /// Creates a new `VariableMetadata`.
    public init() {
        // Intentionally empty
    }


    /// Returns the value for the metadata key stored within the receiver.
    public subscript<Key>(key: Key.Type) -> Key.Value where Key: VariableMetadataKey {
        get {
            let defaultValue = key.defaultValue

            // We need to pass a default value to the Dictionary subscript to differentiate between `nil` and absent
            // values. If we don't pass a default value and use ?? instead, this function will return nil instead of
            // the default value
            return metadata[ObjectIdentifier(key), default: HashableSendableWrapper(defaultValue)].value as! Key.Value
        }
        set {
            let objectID = ObjectIdentifier(key)
            metadata[objectID] = HashableSendableWrapper(newValue)
            displayText[objectID] = DisplayText(key: Key.keyDisplayText, value: Key.displayText(for: newValue))
        }
    }


    /// The instance's display text entries.
    var displayTextEntries: [DisplayText] {
        return Array(displayText.values)
    }
}
