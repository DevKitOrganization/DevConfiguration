# TelemetryAccessReporter Test Plan

Created by Duncan Lewis, 2026-01-07

- TelemetryAccessReporter
  - init
    - init stores parameters
  - report(_:) - Success Cases
    - report(_:) posts DidAccessVariableBusEvent on successful access
    - report(_:) extracts key from event.metadata.key.description
    - report(_:) extracts value from event.result.success.content
    - report(_:) extracts source from event.providerResults.first.providerName
    - report(_:) uses "unknown" source when providerResults is empty
    - report(_:) sets usedFallback to false
  - report(_:) - Error Cases
    - report(_:) posts DidFailToAccessVariableBusEvent when result is failure
    - report(_:) extracts error from event.result.failure
    - report(_:) posts DidFailToAccessVariableBusEvent when result is success(nil)
    - report(_:) uses MissingValueError when result is success(nil)
