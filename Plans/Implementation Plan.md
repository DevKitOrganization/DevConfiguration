# DevConfiguration Implementation Plan

Created by Duncan Lewis, 2026-01-02

---

## Feature Inventory

### Sliced for Implementation
- [ ] Slice 1: ConfigVariable + StructuredConfigReader + ConfigurationDataSource + Telemetry
- [ ] Slice 2: Rich types (Codable)
- [ ] Slice 3: Remote provider support
- [ ] Slice 4: Access caching
- [ ] Slice 5: Registration + Metadata + RegisteredVariablesProvider
- [ ] Slice 6: Editor UI

### Future Features (Deferred)
- [ ] Consumer update signals (@Observable/AsyncStream)
- [ ] Configuration sets (enable/disable groups via Editor UI)

---

## Implementation Slices

### Slice 1: ConfigVariable + StructuredConfigReader + ConfigurationDataSource + Telemetry
**Value:** End-to-end variable access with observability + standard provider setup

**Composed Reader Architecture:**
- **StructuredConfigReader**: Core typed accessor with telemetry (low-level)
- **ConfigurationDataSource**: High-level convenience with standard provider management

**Scope:**
- ConfigVariable<T> struct with ConfigKey storage (primitives + arrays: Bool, String, Int, Double, [Bool], [String], [Int], [Double])
- StructuredConfigurationReading protocol (8 method overloads: 4 primitives + 4 arrays)
- StructuredConfigReader (core type):
  - Low-level init with providers array + eventBus
  - TelemetryAccessReporter integration (AccessReporter protocol)
  - value(for:) implementations using required accessors (requiredBool(), requiredStringArray(), etc.)
  - Error handling: catch errors, return fallback
- ConfigurationDataSource (convenience type):
  - Standard init (auto-configures: source overrides → CLI → environment)
  - Low-level init (custom providers)
  - Protocol delegation to StructuredConfigReader
  - Explicit source override provider creation (not by array index)
- Telemetry events using ConfigContent (from swift-configuration):
  - DidAccessVariableBusEvent (via AccessReporter)
  - VariableResolutionFailedBusEvent (on error)

---

### Slice 2: Rich Types (Codable)
**Value:** Support complex configuration types

**Scope:**
- JSONDecodableValue<T: Decodable> bridge type (ExpressibleByConfigString)
- ConfigVariable<T: Codable> support
- StructuredConfigurationReading.value<T: Codable>(for:) overload
- VariableTypeMismatchBusEvent (decode failure telemetry)

---

### Slice 3: Remote Provider Support
**Value:** Async configuration sources

**Scope:**
- RemoteConfigProvider protocol (isReady, fetch())
- StructuredConfigReader async init
- Provider lifecycle (fetch triggers cache clear + update signal)
- Update signal mechanism (decide: @Observable vs AsyncStream)

---

### Slice 4: Access Caching
**Value:** Performance optimization, telemetry deduplication

**Scope:**
- CacheKey (variableName + ObjectIdentifier(T.self))
- CacheEntry (type-erased storage)
- Cache storage in StructuredConfigReader
- Cache lookup in value(for:) methods
- Cache invalidation (fetch, registration, snapshot change)

---

### Slice 5: Registration + Metadata + Fallbacks
**Value:** Variable validation and extensibility

**Scope:**
- VariableMetadataKey protocol
- VariableMetadata struct (subscript access)
- ConfigVariable metadata storage + .metadata(_:_:) builder
- ConfigVariable dynamic member lookup for metadata
- RegisteredVariablesProvider (internal ConfigProvider composing MutableInMemoryProvider)
- StructuredConfigReader.register() method overloads (9 total: 8 concrete + 1 generic Codable)
- DidAccessUnregisteredVariableBusEvent
- DuplicateVariableRegistrationBusEvent

---

### Slice 6: Editor UI
**Value:** Runtime configuration override interface

**Scope:**
- TBD based on architecture decisions

---

## Context

### Composed Reader Architecture
- **StructuredConfigReader**: Core typed accessor
  - Low-level init with explicit provider array
  - Integrates with swift-configuration's AccessReporter for telemetry
  - Implements StructuredConfigurationReading protocol
- **ConfigurationDataSource**: High-level convenience wrapper
  - Composes StructuredConfigReader
  - Standard init with auto-configured providers
  - Delegates all value access to StructuredConfigReader

### Type System
- Primitives: Bool, String, Int, Double (no Float)
- Arrays: [Bool], [String], [Int], [Double]
- Rich types: T: Codable (requires both Encodable + Decodable for registration)
- Type dispatch: Method overloads for compile-time resolution
- ConfigKey storage: ConfigVariable stores ConfigKey (not String) with two initializers

### Provider Precedence (Standard Stack)
1. Source Code Overrides (MutableInMemoryProvider)
2. Command Line Arguments (CommandLineArgumentsProvider)
3. Environment Variables (EnvironmentVariablesProvider)
4. RegisteredVariablesProvider (internal, lowest priority - Slice 5)
5. ConfigVariable.fallback (inline, used if all providers fail)

### Telemetry Behavior
- Emitted via EventBus (passed at init)
- Success: Posted automatically via TelemetryAccessReporter (AccessReporter integration)
- Failure: Posted directly from catch blocks
- Uses ConfigContent from swift-configuration (not custom enum)
- Errors don't propagate to callers
- Access telemetry emitted once per cache lifecycle (Slice 4)
- Cached reads skip telemetry (Slice 4)

### Codable Bridge Strategy
- Internal JSONDecodableValue<T> wrapper conforms to ExpressibleByConfigString
- Consumers use Codable directly, no additional conformance
- Fallback provider stores Codable types as JSON-encoded strings

### Open Decisions
- Update signal mechanism (Slice 3): @Observable vs AsyncStream
- ExpressibleByConfigString fallthrough on init failure (impacts Slice 2 error handling)
