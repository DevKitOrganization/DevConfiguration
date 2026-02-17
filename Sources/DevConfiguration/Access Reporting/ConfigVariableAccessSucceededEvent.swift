//
//  ConfigVariableAccessSucceededEvent.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 1/7/2026.
//

import Configuration
import DevFoundation

/// A bus event posted when a configuration variable is successfully accessed.
public struct ConfigVariableAccessSucceededEvent: BusEvent {
    /// The configuration key that was accessed.
    public let key: AbsoluteConfigKey

    /// The resolved configuration value.
    public let value: ConfigValue

    /// The name of the provider that supplied the value.
    public let providerName: String?


    /// Creates a new `ConfigVariableAccessSucceededEvent` with the specified parameters.
    ///
    /// - Parameters:
    ///   - key: The configuration key that was accessed.
    ///   - value: The resolved configuration value.
    ///   - providerName: The name of the provider that supplied the value.
    public init(key: AbsoluteConfigKey, value: ConfigValue, providerName: String?) {
        self.key = key
        self.value = value
        self.providerName = providerName
    }
}
