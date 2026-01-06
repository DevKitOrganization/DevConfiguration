# Slice 1: Detailed Implementation Plan

Created by Duncan Lewis, 2026-01-03
**Last Updated:** 2026-01-03 (Decisions Finalized)

**Parent Document:** [Implementation Plan.md](./Implementation%20Plan.md)

---

## Overview

**Slice 1 Scope:** ConfigVariable + StructuredConfigurationReading + Telemetry + Standard Init

**Value Delivered:** End-to-end variable access with observability and standard provider setup

**Supported Types:**
- **Primitives:** `Bool`, `String`, `Int`, `Double`
- **Arrays:** `[Bool]`, `[String]`, `[Int]`, `[Double]`

---

## Architecture

**Two-Type Design:**
1. **StructuredConfigReader**: Core type for typed value access and telemetry
2. **ConfigurationVariableDataSource**: High-level convenience with default provider management

**Division of Responsibilities:**

| Concern | StructuredConfigReader | ConfigurationVariableDataSource |
|---------|------------------------|----------------------------------|
| Value resolution | ✅ Implements | ❌ Delegates |
| Telemetry | ✅ Emits events | ❌ Transparent |
| Caching | ✅ Manages cache (Slice 4) | ❌ Transparent |
| Provider stack | ❌ Accepts array | ✅ Configures defaults |
| Override API | ❌ Not exposed | ✅ Public methods (Slice 6) |
| swift-config integration | ✅ Direct usage | ❌ Via StructuredConfigReader |
| Standard init | ❌ No defaults | ✅ Auto-configures |

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

---

### 5. ConfigurationVariableDataSource (Convenience Type)

**Purpose:** High-level convenience with standard provider management

**Public Interface:**
```swift
public final class ConfigurationVariableDataSource: StructuredConfigurationReading {
    /// Standard init: auto-configured providers
    public init(eventBus: EventBus)

    /// Low-level init: custom providers
    public init(providers: [any ConfigProvider], eventBus: EventBus)

    // Protocol conformance: delegates to StructuredConfigReader (8 overloads)
    public func value(for variable: ConfigVariable<Bool>) -> Bool
    public func value(for variable: ConfigVariable<[Bool]>) -> [Bool]
    // ... etc

    // Source override API (Slice 6 - deferred)
    // public func setOverride<T>(_ value: T, for variable: ConfigVariable<T>)
    // public func clearOverride<T>(for variable: ConfigVariable<T>)
}
```

**Standard Init Implementation:**
```swift
public init(eventBus: EventBus) {
    // Create source override provider EXPLICITLY (not by array index)
    let sourceOverrideProvider = MutableInMemoryProvider(
        name: "source-overrides",
        initialValues: [:]
    )

    // Build provider array
    let providers: [any ConfigProvider] = [
        sourceOverrideProvider,                // Highest precedence
        CommandLineArgumentsProvider(),
        EnvironmentVariablesProvider(),
        // RegisteredVariablesProvider() - Slice 5
    ]

    // Create core reader
    self.reader = StructuredConfigReader(
        providers: providers,
        eventBus: eventBus
    )

    // Store provider reference for Editor UI (Slice 6)
    self.sourceOverrideProvider = sourceOverrideProvider
}

// Protocol delegation
public func value(for variable: ConfigVariable<Bool>) -> Bool {
    reader.value(for: variable)
}
// ... etc for all 8 overloads
```

**Key Design Decisions:**
- Source override provider created **explicitly** before array
- Stored directly (not via array index)
- Delegates all `value(for:)` calls to StructuredConfigReader
- Both classes (not structs) for mutable state
- Low-level init available for advanced use cases

---

### 6. Telemetry Events

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

## Standard Provider Stack

**ConfigurationVariableDataSource Standard Init:**

**Precedence (High → Low):**
1. **Source Code Overrides** - `MutableInMemoryProvider`
   - Name: "source-overrides"
   - Empty initial values
   - Created explicitly, stored for Editor UI (Slice 6)

2. **Command Line Arguments** - `CommandLineArgumentsProvider`
   - Requires `CommandLineArgumentsSupport` trait
   - Pattern: `--feature.darkMode=true`, `--tags swift config`

3. **Environment Variables** - `EnvironmentVariablesProvider`
   - Key transformation: `feature.darkMode` → `FEATURE_DARKMODE`

4. **Registered Fallbacks** - (Slice 5)
   - `RegisteredVariablesProvider` (custom, composes MutableInMemoryProvider)
   - Lowest precedence, above inline fallback

**Not Included:**
- JSON file providers (use low-level init)
- Remote providers (Slice 3)

**Rationale:**
- Covers 90% use case: local development + testing
- Production configs (JSON, remote) require explicit setup

---

## Package.swift Configuration

### Enable CommandLineArgumentsSupport Trait

```swift
.target(
    name: "DevConfiguration",
    dependencies: [
        .product(name: "Configuration", package: "swift-configuration"),
        .product(name: "DevFoundation", package: "DevFoundation"),
    ],
    swiftSettings: [
        .define("CommandLineArguments")
    ]
)
```

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
5. **ConfigurationVariableDataSource** - implement with TODOs (if needed):
   - Standard init with explicit provider creation
   - Protocol delegation (8 overloads)
6. **Fill in remaining data types** (if any)
7. **Enable `CommandLineArgumentsSupport`** in Package.swift
8. **End-to-end verification**

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

**ConfigurationVariableDataSource:**
- Standard init provider stack
- Provider precedence
- Explicit provider creation (not array index)
- Protocol delegation (all 8 overloads)

**Integration Tests:**
- End-to-end value resolution
- Provider precedence verification
- CLI argument parsing
- Environment variable transformation
- Telemetry event flow (both success and failure)

### Test Patterns
- Use `InMemoryProvider` for deterministic tests
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
- [ ] Standard provider stack: overrides → CLI → env
- [ ] Source override provider created explicitly (not by index)
- [ ] `CommandLineArgumentsSupport` trait enabled
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
- Too app-specific for standard stack
- Use low-level init for custom file providers

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
| CLI provider | Enable trait, include in stack |
| Error Sendability | `any Error` is Sendable (verified) |
| isSecret | Defer to Slice 5 metadata |
| AccessReporter | Implement for telemetry |
| JSON provider | Exclude, add as future feature |
| Array support | Add 4 array overloads |
| Provider creation | Explicit creation, not array index |

---

## Next Steps

1. ✅ **Planning complete** (this document)
2. **Begin implementation** following sequence above
3. **Create unit tests** in worktree after implementation
4. **Verify success criteria** before marking Slice 1 complete
