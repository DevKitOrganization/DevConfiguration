//
//  DidFailToAccessVariableBusEvent.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 1/7/2026.
//

import Configuration
import DevFoundation

/// Posted when a configuration variable fails to resolve from any provider.
public struct DidFailToAccessVariableBusEvent: BusEvent {
    /// The configuration key that failed to resolve.
    public let key: String

    /// The error that caused the resolution failure.
    public let error: any Error


    /// Creates a new `DidFailToAccessVariableBusEvent` with the specified parameters.
    ///
    /// - Parameters:
    ///   - key: The configuration key that failed to resolve.
    ///   - error: The error that caused the resolution failure.
    public init(key: String, error: any Error) {
        self.key = key
        self.error = error
    }
}
