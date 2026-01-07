# StructuredConfigReader Test Plan

Created by Duncan Lewis, 2026-01-07

## StructuredConfigReader

### Initialization
- init stores providers array
- init stores eventBus reference
- init creates ConfigReader with providers

### Bool Overload
- value(for:) returns provider value when available
- value(for:) returns provider value from highest priority provider
- value(for:) returns fallback when provider throws
- value(for:) returns fallback when key not found
- value(for:) returns fallback on type mismatch
- value(for:) with .auto privacy passes isSecret: false
- value(for:) with .private privacy passes isSecret: true
- value(for:) with .public privacy passes isSecret: false

### [Bool] Array Overload
- value(for:) returns provider array value when available
- value(for:) returns provider value from highest priority provider
- value(for:) returns fallback array when provider throws
- value(for:) returns fallback array when key not found
- value(for:) returns fallback array on type mismatch
- value(for:) with .auto privacy passes isSecret: false
- value(for:) with .private privacy passes isSecret: true
- value(for:) with .public privacy passes isSecret: false

### String Overload
- value(for:) returns provider value when available
- value(for:) returns fallback when provider throws
- value(for:) returns fallback when key not found
- value(for:) returns fallback on type mismatch
- value(for:) with .auto privacy passes isSecret: true
- value(for:) with .private privacy passes isSecret: true
- value(for:) with .public privacy passes isSecret: false

### Int Overload
- value(for:) returns provider value when available
- value(for:) returns fallback when provider throws
- value(for:) returns fallback when key not found
- value(for:) returns fallback on type mismatch
- value(for:) with .auto privacy passes isSecret: false
- value(for:) with .private privacy passes isSecret: true
- value(for:) with .public privacy passes isSecret: false

### Float64 Overload
- value(for:) returns provider value when available
- value(for:) returns fallback when provider throws
- value(for:) returns fallback when key not found
- value(for:) returns fallback on type mismatch
- value(for:) with .auto privacy passes isSecret: false
- value(for:) with .private privacy passes isSecret: true
- value(for:) with .public privacy passes isSecret: false

### [String] Array Overload
- value(for:) returns provider array value when available
- value(for:) returns fallback array when provider throws
- value(for:) returns fallback array when key not found
- value(for:) returns fallback array on type mismatch
- value(for:) with .auto privacy passes isSecret: true
- value(for:) with .private privacy passes isSecret: true
- value(for:) with .public privacy passes isSecret: false

### [Int] Array Overload
- value(for:) returns provider array value when available
- value(for:) returns fallback array when provider throws
- value(for:) returns fallback array when key not found
- value(for:) returns fallback array on type mismatch
- value(for:) with .auto privacy passes isSecret: false
- value(for:) with .private privacy passes isSecret: true
- value(for:) with .public privacy passes isSecret: false

### [Float64] Array Overload
- value(for:) returns provider array value when available
- value(for:) returns fallback array when provider throws
- value(for:) returns fallback array when key not found
- value(for:) returns fallback array on type mismatch
- value(for:) with .auto privacy passes isSecret: false
- value(for:) with .private privacy passes isSecret: true
- value(for:) with .public privacy passes isSecret: false

### Telemetry (TODO)
- Success telemetry via AccessReporter
- Failure telemetry via VariableResolutionFailedBusEvent