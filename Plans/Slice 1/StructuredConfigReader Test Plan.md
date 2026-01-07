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

### [Bool] Array Overload
- value(for:) returns provider array value when available
- value(for:) returns provider value from highest priority provider
- value(for:) returns fallback array when provider throws
- value(for:) returns fallback array when key not found
- value(for:) returns fallback array on type mismatch

### String Overload
- value(for:) returns provider value when available
- value(for:) returns fallback when provider throws
- value(for:) returns fallback when key not found
- value(for:) returns fallback on type mismatch

### Int Overload
- value(for:) returns provider value when available
- value(for:) returns fallback when provider throws
- value(for:) returns fallback when key not found
- value(for:) returns fallback on type mismatch

### Float64 Overload
- value(for:) returns provider value when available
- value(for:) returns fallback when provider throws
- value(for:) returns fallback when key not found
- value(for:) returns fallback on type mismatch

### [String] Array Overload
- value(for:) returns provider array value when available
- value(for:) returns fallback array when provider throws
- value(for:) returns fallback array when key not found
- value(for:) returns fallback array on type mismatch

### [Int] Array Overload
- value(for:) returns provider array value when available
- value(for:) returns fallback array when provider throws
- value(for:) returns fallback array when key not found
- value(for:) returns fallback array on type mismatch

### [Float64] Array Overload
- value(for:) returns provider array value when available
- value(for:) returns fallback array when provider throws
- value(for:) returns fallback array when key not found
- value(for:) returns fallback array on type mismatch

### Privacy Logic (TODO)
- To be tested after isSecret helper implementation

### Telemetry (TODO)
- Success telemetry via AccessReporter
- Failure telemetry via VariableResolutionFailedBusEvent