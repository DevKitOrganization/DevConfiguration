# DevConfiguration Implementation Plan

Created by Duncan Lewis, 2026-01-02

---

## Feature Inventory

### Sliced for Implementation
- [ ] Slice 1: ConfigVariable + ConfigurationReading + Telemetry + Standard Init
- [ ] Slice 2: Rich types (Codable)
- [ ] Slice 3: Remote provider support
- [ ] Slice 4: Access caching
- [ ] Slice 5: Registration + Metadata + RegisteredFallbacksProvider
- [ ] Slice 6: Editor UI

### Future Features (Deferred)
- [ ] Consumer update signals (@Observable/AsyncStream)
- [ ] Configuration sets (enable/disable groups via Editor UI)

---

## Implementation Slices

### Slice 1: ConfigVariable + ConfigurationReading + Telemetry + Standard Init
**Value:** End-to-end variable access with observability + standard provider setup

**Scope:**
- ConfigVariable<T> struct (Bool, String, Int, Double only)
- ConfigurationReading protocol (4 method overloads)
- StructuredConfigReader (low-level init with providers + eventBus)
- Standard initializer (auto-populates: Editor UI provider, source code override provider, command line provider, registration provider)
- value(for:) implementations (dispatch to ConfigReader, catch errors, return fallback)
- DidAccessVariableBusEvent
- VariableResolutionFailedBusEvent
- Source code override provider (use swift-config's MutableInMemoryProvider)

---

### Slice 2: Rich Types (Codable)
**Value:** Support complex configuration types

**Scope:**
- JSONDecodableValue<T: Decodable> bridge type (ExpressibleByConfigString)
- ConfigVariable<T: Codable> support
- ConfigurationReading.value<T: Codable>(for:) overload
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
- RegistrableVariable protocol
- ConfigVariable conditional conformances (Bool, String, Int, Double, Codable)
- RegisteredFallbacksProvider (internal ConfigProvider)
- StructuredConfigReader.register() methods
- DidAccessUnregisteredVariableBusEvent
- DuplicateVariableRegistrationBusEvent

---

### Slice 6: Editor UI
**Value:** Runtime configuration override interface

**Scope:**
- TBD based on architecture decisions

---

## Context

### Type System
- Primitives: Bool, String, Int, Double (no Float)
- Rich types: T: Codable (requires both Encodable + Decodable for registration)
- Type dispatch: Method overloads for compile-time resolution

### Provider Precedence
1. User-supplied providers (in order passed to init)
2. RegisteredFallbacksProvider (internal, lowest priority)
3. ConfigVariable.fallback (inline, used if all providers fail)

### Telemetry Behavior
- Emitted via EventBus (passed at init)
- Errors don't propagate to callers
- Access telemetry emitted once per cache lifecycle
- Cached reads skip telemetry

### Codable Bridge Strategy
- Internal JSONDecodableValue<T> wrapper conforms to ExpressibleByConfigString
- Consumers use Codable directly, no additional conformance
- Fallback provider stores Codable types as JSON-encoded strings

### Open Decisions
- Update signal mechanism (Slice 3): @Observable vs AsyncStream
- ExpressibleByConfigString fallthrough on init failure (impacts Slice 2 error handling)
