# Slice 1: Detailed Implementation Plan

Created by Duncan Lewis, 2026-01-03
**Last Updated:** 2026-01-03 (Decisions Finalized)

**Parent Document:** [Implementation Plan.md](./Implementation%20Plan.md)

---

## Overview

**Slice 1 Scope:** ConfigVariable + StructuredConfigurationReading + Telemetry

**Value Delivered:** End-to-end variable access with observability

**Supported Types:**
- **Primitives:** `Bool`, `String`, `Int`, `Double`
- **Arrays:** `[Bool]`, `[String]`, `[Int]`, `[Double]`

---

## Architecture

**Simplified Single-Type Design:**
- **StructuredConfigReader**: Single public type for typed configuration access
- Consumers manage their own provider stacks
- Protocol extensions provide typed access

**Responsibilities:**
- Value resolution via protocol extensions
- Telemetry via AccessReporter integration
- Internal RegisteredVariablesProvider management (Slice 3)
- Error handling (catch errors, return fallback)

**Does NOT Handle:**
- Provider stack composition (consumer's responsibility)
- Caching (deferred)

See [Architecture Plan.md](./Architecture%20Plan.md) section 5 for architectural overview.

---

## Key Design Decisions (Finalized)

### 1. ConfigKey Storage
✅ ConfigVariable stores `ConfigKey` directly (not String)
✅ Two initializers: `init(key: String, fallback:)` and `init(key: ConfigKey, fallback:)`
✅ Consumer controls key parsing strategy

### 2. Array Support
✅ Add array accessors for all primitive types
✅ Protocol includes 8 overloads total (4 primitives + 4 arrays)
✅ Maps to swift-configuration's array accessors

### 3. Required Accessors + AccessReporter
✅ Use throwing `requiredBool()`, `requiredString()`, etc.
✅ AccessReporter posts `DidAccessVariableBusEvent` **directly**
✅ No need to track "last accessed provider" - AccessEvent has all info
✅ Errors captured and posted as `VariableResolutionFailedBusEvent`

### 4. Provider Stack
✅ Source overrides created **explicitly**, not by array index
✅ CLI provider enabled via `CommandLineArgumentsSupport` trait
✅ Precedence: Source Overrides → CLI → Environment → Registration (Slice 5)

### 5. Deferred to Later Slices
- `isSecret` parameter → Slice 5 (metadata)
- JSON file providers → Future (as "variable overlays")
- Caching → Slice 4

---

## Component Breakdown

### 1. ConfigVariable<T>

**Purpose:** Type-safe variable definition with fallback value

**Public Interface:**
```swift
public struct ConfigVariable<Value> {
    public let key: ConfigKey
    public let fallback: Value

    // Convenience: string → ConfigKey
    public init(key: String, fallback: Value)

    // Direct: explicit ConfigKey
    public init(key: ConfigKey, fallback: Value)
}
```

**Supported Types in Slice 1:**
- Primitives: `Bool`, `String`, `Int`, `Double`
- Arrays: `[Bool]`, `[String]`, `[Int]`, `[Double]`

**Example Usage:**
```swift
enum AppConfig {
    static let darkMode = ConfigVariable(key: "feature.darkMode", fallback: false)
    static let tags = ConfigVariable(key: "feature.tags", fallback: ["default"])
    static let timeout = ConfigVariable(key: ConfigKey("network.timeout"), fallback: 30.0)
}

// Access
let darkMode = dataSource.value(for: AppConfig.darkMode)
let tags = dataSource.value(for: AppConfig.tags)
```

---

### 2. StructuredConfigurationReading Protocol

**Purpose:** Define contract for typed configuration access

**Public Interface:**
```swift
public protocol StructuredConfigurationReading {
    // Primitives (4 overloads)
    func value(for variable: ConfigVariable<Bool>) -> Bool
    func value(for variable: ConfigVariable<String>) -> String
    func value(for variable: ConfigVariable<Int>) -> Int
    func value(for variable: ConfigVariable<Double>) -> Double

    // Arrays (4 overloads)
    func value(for variable: ConfigVariable<[Bool]>) -> [Bool]
    func value(for variable: ConfigVariable<[String]>) -> [String]
    func value(for variable: ConfigVariable<[Int]>) -> [Int]
    func value(for variable: ConfigVariable<[Double]>) -> [Double]
}
```

**Key Design Decisions:**
- 8 method overloads total (4 primitives + 4 arrays)
- Compile-time dispatch, no generic constraints
- Always returns non-optional (fallback on error)
- No `throws` - errors captured in telemetry
- Synchronous only (async in Slice 3)

---

### 3. TelemetryAccessReporter (Internal)

**Purpose:** Bridge swift-configuration access reporting to EventBus telemetry

**Implementation:**
```swift
internal final class TelemetryAccessReporter: AccessReporter, Sendable {
    private let eventBus: EventBus

    init(eventBus: EventBus) {
        self.eventBus = eventBus
    }

    func reportAccess(_ event: AccessEvent) {
        // Extract ConfigContent from AccessEvent result
        guard case .success(let configValue) = event.result,
              let configValue = configValue else {
            return  // Don't post event for failed access (TODO: check whether we can get the necessary failure info here)
        }

        eventBus.post(DidAccessVariableBusEvent(
            key: event.metadata.key.description,
            value: configValue.content,  // ConfigContent from ConfigValue
            source: event.providerResults.first?.providerName ?? "unknown",
            usedFallback: false  // Successful access from provider
        ))
    }
}
```

**Key Design Decisions:**
- **Posts events directly** - no "last source" tracking needed
- Extracts `ConfigContent` from `AccessEvent.result.success.content`
- Uses swift-configuration's `ConfigContent` type directly
- Sendable for thread-safety
- Owned by StructuredConfigReader
- Converts `AccessEvent` to `DidAccessVariableBusEvent`

---

### 4. StructuredConfigReader (Core Type)

**Purpose:** Core typed configuration accessor with telemetry

**Public Interface:**
```swift
public final class StructuredConfigReader: StructuredConfigurationReading {
    public init(providers: [any ConfigProvider], eventBus: EventBus)

    // Protocol conformance (8 overloads)
    public func value(for variable: ConfigVariable<Bool>) -> Bool
    public func value(for variable: ConfigVariable<[Bool]>) -> [Bool]
    // ... etc for all 8 types
}
```

**Internal Implementation:**
```swift
public final class StructuredConfigReader: StructuredConfigurationReading {
    private let reader: ConfigReader
    private let eventBus: EventBus
    private let accessReporter: TelemetryAccessReporter

    public init(providers: [any ConfigProvider], eventBus: EventBus) {
        self.eventBus = eventBus
        self.accessReporter = TelemetryAccessReporter(eventBus: eventBus)
        self.reader = ConfigReader(
            providers: providers,
            accessReporter: accessReporter  // Install reporter
        )
    }

    // Primitive example
    public func value(for variable: ConfigVariable<Bool>) -> Bool {
        do {
            // Required accessor throws if not found or type mismatch
            let resolved = try reader.requiredBool(forKey: variable.key)
            // AccessReporter already posted DidAccessVariableBusEvent
            return resolved
        } catch {
            // Error: post failure event
            eventBus.post(VariableResolutionFailedBusEvent(
                key: variable.key.description,
                error: error,
                fallback: .bool(variable.fallback)
            ))
            return variable.fallback
        }
    }

    // Array example
    public func value(for variable: ConfigVariable<[String]>) -> [String] {
        do {
            let resolved = try reader.requiredStringArray(forKey: variable.key)
            // AccessReporter already posted event
            return resolved
        } catch {
            eventBus.post(VariableResolutionFailedBusEvent(
                key: variable.key.description,
                error: error,
                fallback: .stringArray(variable.fallback)
            ))
            return variable.fallback
        }
    }

    // ... 6 more overloads
}
```

**Key Design Decisions:**
- Use `requiredBool()`, `requiredStringArray()`, etc. (throwing accessors)
- AccessReporter posts success telemetry **automatically**
- Only post failure telemetry in catch block
- Fallback always returned on error
- No manual source tracking - AccessEvent has provider name
- Protocol extensions provide default implementations

**Example Usage:**
```swift
// Consumer creates their own provider stack
let providers: [any ConfigProvider] = [
    EnvironmentVariablesProvider(),
    // RegisteredVariablesProvider automatically added by StructuredConfigReader (Slice 3)
]

let reader = StructuredConfigReader(
    providers: providers,
    eventBus: eventBus
)

let darkMode = reader.value(for: .darkMode)
```

---

### 5. Telemetry Events

**DidAccessVariableBusEvent:**
```swift
public struct DidAccessVariableBusEvent: BusEvent {
    public let key: String
    public let value: ConfigContent  // From swift-configuration
    public let source: String  // Provider name from AccessEvent
    public let usedFallback: Bool

    public init(key: String, value: ConfigContent, source: String, usedFallback: Bool)
}
```

**VariableResolutionFailedBusEvent:**
```swift
public struct VariableResolutionFailedBusEvent: BusEvent {
    public let key: String
    public let error: any Error  // Sendable in Swift 6
    public let fallback: ConfigContent  // From swift-configuration

    public init(key: String, error: any Error, fallback: ConfigContent)
}
```

**Key Design Decisions:**
- Uses `ConfigContent` from swift-configuration (not custom enum)
- `ConfigContent` has all needed cases: bool, string, int, double, plus array variants
- Posted via AccessReporter for successful accesses
- Posted directly for failures
- `any Error` is Sendable in Swift 6 (verified)

---

## swift-configuration Integration

### Typed Accessors Used

**Primitives (throwing):**
- `requiredBool(forKey:) throws -> Bool`
- `requiredString(forKey:) throws -> String`
- `requiredInt(forKey:) throws -> Int`
- `requiredDouble(forKey:) throws -> Double`

**Arrays (throwing):**
- `requiredBoolArray(forKey:) throws -> [Bool]`
- `requiredStringArray(forKey:) throws -> [String]`
- `requiredIntArray(forKey:) throws -> [Int]`
- `requiredDoubleArray(forKey:) throws -> [Double]`

### AccessReporter Protocol
```swift
public protocol AccessReporter {
    func reportAccess(_ event: AccessEvent)
}

public struct AccessEvent {
    public let key: AbsoluteConfigKey
    public let value: ConfigValue?
    public let providerName: String
    // ... other fields
}
```

**Key Benefits:**
- AccessEvent contains provider name - no manual tracking needed
- Thrown errors contain full context (key, type, provider info)
- AccessReporter integrates seamlessly with ConfigReader

---

## Example Provider Stacks

**Consumer-Managed Configuration:**

Consumers manage their own provider stacks by passing an array of providers to `StructuredConfigReader`. Provider order determines precedence (first = highest priority). `RegisteredVariablesProvider` is automatically appended internally (Slice 3) at lowest precedence.

**Example: Local Development**
```swift
let providers: [any ConfigProvider] = [
    EnvironmentVariablesProvider(),
]

let reader = StructuredConfigReader(
    providers: providers,
    eventBus: eventBus
)
```

**Example: Testing with Overrides**
```swift
let overrides = MutableInMemoryProvider(
    name: "test-overrides",
    initialValues: ["feature.darkMode": true]
)

let providers: [any ConfigProvider] = [
    overrides,
    EnvironmentVariablesProvider(),
]

let reader = StructuredConfigReader(providers: providers, eventBus: eventBus)
```

**Example: Production with CLI Support**
```swift
let providers: [any ConfigProvider] = [
    CommandLineArgumentsProvider(),  // Requires CommandLineArgumentsSupport trait
    EnvironmentVariablesProvider(),
    // Add JSON/file providers as needed
]

let reader = StructuredConfigReader(providers: providers, eventBus: eventBus)
```

**Notes:**
- CLI arguments pattern: `--feature.darkMode=true`, `--tags swift config`
- Environment key transformation: `feature.darkMode` → `FEATURE_DARKMODE`
- JSON/file providers: Consumer adds as needed for their use case
- Remote providers: See Slice 2 for async provider support

---

## Implementation Sequence

**Recommended Order:**
1. **ConfigVariable<T>** - struct with two initializers
2. **StructuredConfigurationReading** - protocol (8 overloads)
3. **StructuredConfigReader** - implement with TODOs:
   - Constructor with AccessReporter integration (TODO: TelemetryAccessReporter)
   - Implement `value(for:)` for Bool (TODO: event types)
   - Implement `value(for:)` for [Bool] (verify array pattern)
   - Complete remaining 6 overloads
4. **Fill in data types for StructuredConfigReader:**
   - `TelemetryAccessReporter` - AccessReporter implementation
   - `DidAccessVariableBusEvent` - struct using ConfigContent
   - `VariableResolutionFailedBusEvent` - struct with `any Error`
5. **End-to-end verification**

**Rationale:**
- Implement main types first with TODOs to define interfaces
- Fill in supporting types as needed to resolve TODOs
- This allows incremental progress and clearer interface design
- Verify primitive and array patterns early (step 3)

---

## Testing Strategy

### Unit Test Coverage

**ConfigVariable:**
- Two initializers (String and ConfigKey)
- Property access

**TelemetryAccessReporter:**
- Event posting from AccessEvent
- EventBus integration
- Conversion from AccessEvent to DidAccessVariableBusEvent

**StructuredConfigReader:**
- All 8 overloads (4 primitives + 4 arrays)
- Required accessor error handling
- Fallback on missing values
- Fallback on type mismatch
- Fallback on provider errors
- Telemetry emission (success via AccessReporter + failure direct)
- Provider array initialization
- AccessReporter integration

**Integration Tests:**
- End-to-end value resolution
- Provider precedence verification
- Environment variable transformation
- Telemetry event flow (both success and failure)
- Multiple provider stack patterns

### Test Patterns
- Use `MutableInMemoryProvider` for deterministic tests
- Mock EventBus to verify telemetry
- Use DevTesting stub framework
- See `Documentation/TestingGuidelines.md`

---

## Success Criteria

**Slice 1 is complete when:**
- [ ] All types compile without errors
- [ ] ConfigVariable supports both initializers (String and ConfigKey)
- [ ] StructuredConfigurationReading has 8 overloads (4 + 4)
- [ ] TelemetryAccessReporter posts events from AccessEvent
- [ ] Value resolution uses required accessors (throwing)
- [ ] AccessReporter handles success telemetry automatically
- [ ] Error telemetry includes full context
- [ ] StructuredConfigReader accepts provider array
- [ ] All 8 type overloads work (primitives + arrays)
- [ ] Provider precedence respected
- [ ] Unit tests achieve >99% coverage
- [ ] Linting passes (`Scripts/lint`)
- [ ] All integration tests pass

---

## Future Features (Deferred)

### Variable Overlays (Post-Slice 1)
- JSON/YAML file-based configuration
- Environment-specific configs (dev, staging, prod)
- Too app-specific for core library
- Consumers add custom file providers to their provider stack

### Caching (Slice 4)
- Cache resolved values by (key, type)
- Cache invalidation on provider updates
- Performance optimization + telemetry deduplication

### Metadata (Slice 5)
- `isSecret` parameter
- Extensible metadata system
- Registration support

---

## DevFoundation Consistency Patterns

**EventBus Usage:**
- Pass `EventBus` at initialization (dependency injection)
- Post events via `eventBus.post(_:)`
- Event types conform to `BusEvent` (Sendable)

**Error Handling:**
- Never propagate errors to API consumers
- Emit telemetry for errors instead
- Return sensible defaults (fallback values)

**Naming Conventions:**
- Types: `<Purpose><Context>` (e.g., `StructuredConfigReader`)
- Events: `Did<Action><Context>BusEvent`
- Properties: camelCase, descriptive

**Dependency Injection:**
- Constructor injection for dependencies (`EventBus`, providers)
- No service locator pattern
- No global state

---

## All Questions Resolved ✅

| Question | Decision |
|----------|----------|
| ConfigKey init | Consumer choice via two initializers |
| Provider attribution | AccessReporter posts events directly |
| CLI provider | Consumer adds to provider stack if needed |
| Error Sendability | `any Error` is Sendable (verified) |
| isSecret | Defer to Slice 5 metadata |
| AccessReporter | Implement for telemetry |
| JSON provider | Consumer adds to provider stack if needed |
| Array support | Add 4 array overloads |
| Standard provider stack | Removed - consumers manage their own |

---

## Next Steps

1. ✅ **Planning complete** (this document)
2. **Begin implementation** following sequence above
3. **Create unit tests** in worktree after implementation
4. **Verify success criteria** before marking Slice 1 complete
