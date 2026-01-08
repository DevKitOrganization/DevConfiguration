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
final class TelemetryAccessReporter: AccessReporter, Sendable {
    /// The event bus that telemetry events are posted on.
    let eventBus: EventBus


    /// Creates a new `TelemetryAccessReporter` with the specified event bus.
    ///
    /// - Parameter eventBus: The event bus that telemetry events are posted on.
    public init(eventBus: EventBus) {
        self.eventBus = eventBus
    }


    func report(_ event: AccessEvent) {
        // Handle the result of the configuration access
        switch event.result {
        case .success(let configValue?):
            eventBus.post(
                DidAccessVariableBusEvent(
                    key: event.metadata.key.description,
                    value: configValue.content,
                    source: event.providerResults.first?.providerName ?? "unknown"
                )
            )

        case .success(nil):
            eventBus.post(
                DidFailToAccessVariableBusEvent(
                    key: event.metadata.key.description,
                    error: MissingValueError()
                )
            )

        case .failure(let error):
            eventBus.post(
                DidFailToAccessVariableBusEvent(
                    key: event.metadata.key.description,
                    error: error
                )
            )
        }
    }
}


// MARK: - Utility Types

/// Error indicating a configuration value was expected but not found.
struct MissingValueError: Error {}
