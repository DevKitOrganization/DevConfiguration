//
//  ConfigVariableDecodingFailedEvent.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/5/2026.
//

import Configuration
import DevFoundation

/// A bus event posted when a configuration variable’s raw value is found but cannot be decoded.
///
/// This is distinct from ``ConfigVariableAccessFailedEvent``, which indicates the key itself could not be resolved
/// from any provider. A decoding failure means the provider returned a value, but it could not be decoded into the
/// expected type.
public struct ConfigVariableDecodingFailedEvent: BusEvent {
    /// The configuration key whose value could not be decoded.
    public let key: AbsoluteConfigKey

    /// The type that the value was being decoded into.
    public let targetType: Any.Type

    /// The decoding error.
    public let error: any Error


    /// Creates a new `ConfigVariableDecodingFailedEvent` with the specified parameters.
    ///
    /// - Parameters:
    ///   - key: The configuration key whose value could not be decoded.
    ///   - targetType: The type that the value was being decoded into.
    ///   - error: The decoding error.
    public init(key: AbsoluteConfigKey, targetType: Any.Type, error: any Error) {
        self.key = key
        self.targetType = targetType
        self.error = error
    }
}
