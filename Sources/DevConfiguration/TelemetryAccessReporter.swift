//
//  TelemetryAccessReporter.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 1/7/2026.
//

import Configuration
import DevFoundation

/// An access reporter that posts access events to an event bus.
///
/// This reporter converts configuration access events into bus events:
///   - Successful accesses post `DidAccessVariableBusEvent`
///   - Failed accesses post `DidFailToAccessVariableBusEvent`
public final class TelemetryAccessReporter: AccessReporter, Sendable {
    /// The event bus that telemetry events are posted on.
    public let eventBus: EventBus


    /// Creates a new `TelemetryAccessReporter` with the specified event bus.
    ///
    /// - Parameter eventBus: The event bus that telemetry events are posted on.
    public init(eventBus: EventBus) {
        self.eventBus = eventBus
    }


    public func report(_ event: AccessEvent) {
        // Handle the result of the configuration access
        switch event.result {
        case .success(let configValue?):
            eventBus.post(
                DidAccessConfigVariableEvent(
                    key: event.metadata.key,
                    value: configValue,
                    source: event.providerResults.first?.providerName ?? "unknown"
                )
            )

        case .success(nil):
            eventBus.post(
                DidFailToAccessConfigVariableEvent(
                    key: event.metadata.key,
                    error: MissingValueError()
                )
            )

        case .failure(let error):
            eventBus.post(
                DidFailToAccessConfigVariableEvent(
                    key: event.metadata.key,
                    error: error
                )
            )
        }
    }
}


// MARK: - Utility Types

/// Error indicating a configuration value was expected but not found.
struct MissingValueError: Error {}
