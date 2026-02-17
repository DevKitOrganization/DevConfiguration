# DevConfiguration Implementation Plan

Created by Duncan Lewis, 2026-01-02

---

## Feature Inventory

### Sliced for Implementation
- [X] Slice 1: ConfigVariable + StructuredConfigReader + Telemetry
- [ ] Slice 2: Remote provider support + update signals
- [ ] Slice 3: Registration + Metadata + RegisteredVariablesProvider
- [ ] Slice 4: Editor UI

### Future Features (Deferred)
- [ ] Rich types (Codable) - may not be needed, can use multi-component ConfigKeys ("foo.bar") for nested access
- [ ] Access caching - may add later for telemetry deduplication only
- [ ] Configuration sets (enable/disable groups via Editor UI)

---

## Implementation Slices

### Slice 1: ConfigVariable + StructuredConfigReader + Telemetry
**Value:** End-to-end variable access with observability

**Architecture:**
- **StructuredConfigReader**: Single typed accessor with telemetry
- Consumers manage their own provider stacks
- Protocol extensions provide typed access

**Scope:**
- ConfigVariable<T> struct with ConfigKey storage (primitives + arrays: Bool, String, Int, Double, [Bool], [String], [Int], [Double])
- StructuredConfigurationReading protocol (8 method overloads: 4 primitives + 4 arrays)
- StructuredConfigReader (single public type):
  - Init with providers array + eventBus (consumers pass their own providers)
  - EventBusAccessReporter integration (AccessReporter protocol)
  - Protocol extension implementations using required accessors (requiredBool(), requiredStringArray(), etc.)
  - Error handling: catch errors, return fallback
  - Composes ConfigReader internally
- Telemetry events using ConfigContent (from swift-configuration):
  - DidAccessVariableBusEvent (via AccessReporter)
  - VariableResolutionFailedBusEvent (on error)

---

### Slice 2: Remote Provider Support + Update Signals
**Value:** Async configuration sources and change notification

**Scope:**
- RemoteConfigProvider protocol (isReady, fetch())
- StructuredConfigReader async init (if needed)
- Provider lifecycle patterns
- Update signal mechanism (decide: @Observable vs AsyncStream vs callback)
- **Validation**: Verify deep keypath access with multi-component ConfigKeys (e.g., "user.settings.theme")

---

### Slice 3: Registration + Metadata + Fallbacks
**Value:** Variable validation and extensibility

**Scope:**
- VariableMetadataKey protocol
- VariableMetadata struct (subscript access)
- ConfigVariable metadata storage + .metadata(_:_:) builder
- ConfigVariable dynamic member lookup for metadata
- RegisteredVariablesProvider (internal ConfigProvider composing MutableInMemoryProvider)
  - Created internally by StructuredConfigReader
  - Automatically added to end of provider array (lowest precedence)
- StructuredConfigReader.register() method overloads (8 concrete + arrays as needed)
- DidAccessUnregisteredVariableBusEvent
- DuplicateVariableRegistrationBusEvent

---

### Slice 4: Editor UI
**Value:** Runtime configuration override interface

**Scope:**
- TBD based on architecture decisions
- Provider-based UI presentation (providers manage their own UI)

---

## Context

### Simplified Architecture
- **StructuredConfigReader**: Single public type for typed configuration access
  - Init with explicit provider array (consumers manage their own stack)
  - Internally creates RegisteredVariablesProvider (Slice 3) appended to provider array
  - Integrates with swift-configuration's AccessReporter for telemetry
  - Implements StructuredConfigurationReading via protocol extensions
  - Composes ConfigReader internally
  - No caching (may add later for telemetry deduplication only)

### Type System
- Primitives: Bool, String, Int, Double (no Float)
- Arrays: [Bool], [String], [Int], [Double]
- Type dispatch: Method overloads for compile-time resolution
- ConfigKey storage: ConfigVariable stores ConfigKey (not String) with two initializers
- Nested access: Use multi-component ConfigKeys ("user.settings.theme") instead of Codable types

### Provider Precedence
Consumers pass their own provider array. Typical precedence pattern:
1. High-priority providers (remote/dynamic sources)
2. Mid-priority providers (environment, CLI args, files)
3. RegisteredVariablesProvider (internal, auto-added by StructuredConfigReader - Slice 3)
4. ConfigVariable.fallback (inline, used if all providers fail)

### Telemetry Behavior
- Emitted via EventBus (passed at init)
- Success: Posted automatically via EventBusAccessReporter (AccessReporter integration)
- Failure: Posted directly from catch blocks
- Uses ConfigContent from swift-configuration (not custom enum)
- Errors don't propagate to callers
- No caching (telemetry posted on every access)

### Codable Bridge Strategy (Deferred)
- Internal JSONDecodableValue<T> wrapper conforms to ExpressibleByConfigString
- Consumers use Codable directly, no additional conformance
- Fallback provider stores Codable types as JSON-encoded strings
- **Note:** May not be needed - multi-component ConfigKeys ("foo.bar") provide nested access

### Open Decisions
- Update signal mechanism (Slice 2): @Observable vs AsyncStream vs callback
- Deep keypath access validation (Slice 2): Verify multi-component ConfigKeys work with remote providers
- ExpressibleByConfigString fallthrough on init failure (deferred, impacts Codable support if implemented)
- Editor UI approach (Slice 4): Provider-managed vs centralized UI
