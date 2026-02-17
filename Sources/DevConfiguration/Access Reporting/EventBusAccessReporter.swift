//
//  EventBusAccessReporter.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 1/7/2026.
//

import Configuration
import DevFoundation

/// An access reporter that posts access events to an event bus.
///
/// This reporter converts configuration access events into bus events:
///
///   - Successful accesses post ``ConfigVariableAccessSucceededEvent``
///   - Failed accesses post ``ConfigVariableAccessFailedEvent``
public struct EventBusAccessReporter: AccessReporter {
    /// The event bus that telemetry events are posted on.
    public let eventBus: EventBus


    /// Creates a new `EventBusAccessReporter` with the specified event bus.
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
                ConfigVariableAccessSucceededEvent(
                    key: event.metadata.key,
                    value: configValue,
                    providerName: event.providerResults.first?.providerName
                )
            )

        case .success(nil):
            eventBus.post(
                ConfigVariableAccessFailedEvent(
                    key: event.metadata.key,
                    error: MissingValueError()
                )
            )

        case .failure(let error):
            eventBus.post(
                ConfigVariableAccessFailedEvent(
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
