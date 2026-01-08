//
//  DidAccessVariableBusEvent.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 1/7/2026.
//

import Configuration
import DevFoundation

/// Posted when a configuration variable is successfully accessed.
public struct DidAccessVariableBusEvent: BusEvent {
    /// The configuration key that was accessed.
    public let key: String

    /// The resolved configuration value.
    public let value: ConfigContent

    /// The name of the provider that supplied the value.
    public let source: String


    /// Creates a new `DidAccessVariableBusEvent` with the specified parameters.
    ///
    /// - Parameters:
    ///   - key: The configuration key that was accessed.
    ///   - value: The resolved configuration value.
    ///   - source: The name of the provider that supplied the value.
    public init(key: String, value: ConfigContent, source: String) {
        self.key = key
        self.value = value
        self.source = source
    }
}
