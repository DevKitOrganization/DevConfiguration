# DevConfiguration Architecture

Typesafe configuration wrapper on Apple's swift-configuration.

---

## 1. Variable Definitions

Variables defined anywhere by consumers; encouraged pattern is static properties on the `ConfigVariable` type:

```swift
extension ConfigVariable where Value == Bool {
    static let darkMode = ConfigVariable(
        key: "feature.darkMode",
        fallback: false
    )
}

// Access: config.value(for: .darkMode)
```

**Key format**: `ConfigKey` (from swift-configuration). Consumers can use string convenience initializer or construct ConfigKey explicitly. Key transformation is provider-specific:
- JSON/YAML: `feature.darkMode` → nested lookup `{ "feature": { "darkMode": ... } }`
- Environment: `feature.darkMode` → `FEATURE_DARKMODE`
- Custom providers: define their own transformation

### Core Types

```swift
@dynamicMemberLookup
public struct ConfigVariable<Value> {
    public let key: ConfigKey  // From swift-configuration
    public let fallback: Value
    public let privacy: VariablePrivacy
    private var metadata: VariableMetadata

    // Convenience: string → ConfigKey
    public init(key: String, fallback: Value)

    // Direct: explicit ConfigKey
    public init(key: ConfigKey, fallback: Value)

    /// Builder-style metadata setter
    public func metadata<M>(_ keyPath: WritableKeyPath<VariableMetadata, M>, _ value: M) -> Self

    /// Dynamic member access to metadata values
    public subscript<M>(dynamicMember keyPath: WritableKeyPath<VariableMetadata, M>) -> M
}
```

### Metadata System

Extensible via SwiftUI Environment-style key pattern:

```swift
public protocol VariableMetadataKey {
    associatedtype Value
    static var defaultValue: Value { get }
    
    /// Display name for editor UI
    static var keyDisplayText: String { get }
    
    /// Value formatting for editor UI
    static func displayText(for value: Value) -> String?
}

public struct VariableMetadata {
    public subscript<K: VariableMetadataKey>(key: K.Type) -> K.Value { get set }
}
```

Consumer-defined metadata:

```swift
// Define key
private struct ExpirationDateKey: VariableMetadataKey {
    static var defaultValue: Date? { nil }
    static var keyDisplayText: String { "Expiration" }
    static func displayText(for value: Date?) -> String? { value?.formatted() }
}

// Extend VariableMetadata
extension VariableMetadata {
    var expirationDate: Date? {
        get { self[ExpirationDateKey.self] }
        set { self[ExpirationDateKey.self] = newValue }
    }
}

// Usage
let flag = ConfigVariable(key: "feature.x", fallback: false)
    .metadata(\.expirationDate, Date.now.addingTimeInterval(5 * 86400))

// Reading
let expires = flag.expirationDate
```

---

## 2. Variable Access

- Always synchronous (async support for remote providers)
- Never fails — fallback returned on error
- Method overloads for compile-time dispatch

```swift
public protocol StructuredConfigurationReading {
    // Primitives
    func value(for variable: ConfigVariable<Bool>) -> Bool
    func value(for variable: ConfigVariable<String>) -> String
    func value(for variable: ConfigVariable<Int>) -> Int
    func value(for variable: ConfigVariable<Float64>) -> Float64

    // Arrays
    func value(for variable: ConfigVariable<[Bool]>) -> [Bool]
    func value(for variable: ConfigVariable<[String]>) -> [String]
    func value(for variable: ConfigVariable<[Int]>) -> [Int]
    func value(for variable: ConfigVariable<[Float64]>) -> [Float64]

    // Rich types
    func value<T: Codable>(for variable: ConfigVariable<T>) -> T
}
```

Resolution dispatches to swift-configuration's typed accessors (`requiredBool()`, `requiredStringArray()`, etc.), catches errors, returns fallback.

### Supported Value Types

| Type | Resolution |
|------|------------|
| `Bool` | `requiredBool(forKey:)` |
| `String` | `requiredString(forKey:)` |
| `Int` | `requiredInt(forKey:)` |
| `Float64` | `requiredDouble(forKey:)` |
| `[Bool]` | `requiredBoolArray(forKey:)` |
| `[String]` | `requiredStringArray(forKey:)` |
| `[Int]` | `requiredIntArray(forKey:)` |
| `[Float64]` | `requiredDoubleArray(forKey:)` |
| `T: Codable` | String → JSON decode |

- Note: Use `Float64` instead of `Double` in the interface to match DevFoundation.

---

## 3. Telemetry

Telemetry emitted via `EventBus` (passed at init). Errors don't propagate to callers — fallback returned, event posted.

Example events:
- `DidAccessVariableBusEvent` — variable accessed (key, value, source, usedFallback)
- `DidAccessUnregisteredVariableBusEvent` — accessed variable not in registry
- `VariableResolutionFailedBusEvent` — error during resolution (key, error, fallback used)

---

## 4. Relationship to swift-configuration

**Uses**: `ConfigReader`, `ConfigProvider` protocol, provider precedence, built-in providers

**Abstracts over**: Typed accessors, per-call defaults, async patterns

**Adds**: `ConfigVariable<T>`, generic access, guaranteed returns, error observation, registration, caching, editor UI

---

## Open Questions

- Consumer-facing update signal: How does `StructuredConfigReader` notify consumers when values may have changed? (`@Observable`, `AsyncStream`, callback, or just re-access?)
- Does `ExpressibleByConfigString` support fallthrough on init failure? (assumed yes, needs verification)

---

## 5. Simplified Architecture

**Design Decision:** Single public type with protocol-based typed access.

### StructuredConfigReader

Typed accessor that bridges `ConfigVariable<T>` to swift-configuration's `ConfigReader`.

```swift
public final class StructuredConfigReader: StructuredConfigurationReading {
    private let reader: ConfigReader
    private let eventBus: EventBus
    private let accessReporter: TelemetryAccessReporter

    /// Initialize with custom provider array
    /// Internally appends RegisteredVariablesProvider to end of array (lowest precedence)
    public init(providers: [any ConfigProvider], eventBus: EventBus)
}

// Protocol conformance via extensions
extension StructuredConfigReader {
    // Protocol conformance: 8 overloads (4 primitives + 4 arrays)
    public func value(for variable: ConfigVariable<Bool>) -> Bool
    public func value(for variable: ConfigVariable<[Bool]>) -> [Bool]
    // ... etc
}
```

**Responsibilities:**
- Value resolution with required accessors (`requiredBool()`, `requiredStringArray()`, etc.)
- Error handling (catch all, return fallback)
- Telemetry emission via AccessReporter integration
- Internal RegisteredVariablesProvider management (appended to provider array)

**Does NOT Handle:**
- Provider stack composition (consumer's responsibility)
- Caching (may add later for telemetry deduplication only)

**Provider Management:**
- Consumers pass their own provider array
- Provider order determines precedence (first = highest priority)
- StructuredConfigReader internally appends RegisteredVariablesProvider to end
- No `addProvider` API — provider order should be explicit at initialization

**Example Usage:**
```swift
// Consumer creates their own provider stack
let providers: [any ConfigProvider] = [
    AmplitudeProvider(),             // Highest priority
    EnvironmentVariablesProvider(),
    // RegisteredVariablesProvider automatically added by StructuredConfigReader
]

let reader = StructuredConfigReader(
    providers: providers,
    eventBus: eventBus
)

let darkMode = reader.value(for: .darkMode)
```

**Async Providers:**
Some providers (e.g., remote services) may not have values immediately:

- Providers initialize synchronously but return no values until ready
- Consumer controls lifecycle via explicit `await provider.fetch()`
- On activation: reader emits update signal (via `@Observable` or stream)
- Multiple remote providers activate independently

```swift
// Remote provider pattern
let amplitudeProvider = AmplitudeProvider(...)
let reader = StructuredConfigReader(
    providers: [amplitudeProvider],
    eventBus: eventBus
)

// Later, when app is ready
await amplitudeProvider.fetch()  // Signal emitted
```

---

## 6. Rich Data Transformation

For Codable types, we bridge to swift-config's `ExpressibleByConfigString` protocol via an internal wrapper.

### Internal Bridge Type

```swift
internal struct JSONDecodableValue<T: Decodable>: ExpressibleByConfigString {
    let value: T
    
    init?(configString: String) {
        guard let data = configString.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        self.value = decoded
    }
}
```

### Codable Access Implementation

```swift
func value<T: Codable>(for variable: ConfigVariable<T>) -> T {
    if let wrapped: JSONDecodableValue<T> = reader.string(
        forKey: variable.key,
        as: JSONDecodableValue<T>.self
    ) {
        return wrapped.value
    }
    return variable.fallback
}
```

**Benefits:**
- Consumers use `Codable` directly — no extra conformance needed
- Leverages swift-config's intended extensibility (`ExpressibleByConfigString`)
- DevConfig owns bridging logic internally

**Limitation:** Fallthrough on transform failure depends on swift-config's behavior (unverified). If unsupported, transform failure returns fallback without trying next provider.

---

## 7. Variable Registration

Registration informs the reader of expected variables, stores fallback values as the lowest-priority provider, and enables configuration validation telemetry.

### Registration API

```swift
extension StructuredConfigReader {
    func register(_ variable: ConfigVariable<Bool>) { … }
    func register(_ variable: ConfigVariable<String>) { … }
    func register(_ variable: ConfigVariable<Int>) { … }
    func register(_ variable: ConfigVariable<Double>) { … }
    func register(_ variable: ConfigVariable<[Bool]>) { … }
    func register(_ variable: ConfigVariable<[String]>) { … }
    func register(_ variable: ConfigVariable<[Int]>) { … }
    func register(_ variable: ConfigVariable<[Double]>) { … }
    func register<Value>(_ variable: ConfigVariable<Value>) where Value: Codable { … }
}
```

Usage:
```swift
structuredReader.register(.darkMode)
structuredReader.register(.timeout)
```

**Note:** Rich types require `Codable` (not just `Decodable`) to support registration — fallback values must be encoded for storage in the internal provider.

### Internal Provider

A custom `ConfigProvider` owned by `StructuredConfigReader`, inserted at lowest precedence:

```swift
internal final class RegisteredVariablesProvider: ConfigProvider {
    private let provider: MutableInMemoryProvider
    private var registeredKeys: Set<String> = []
    private var metadata: [String: VariableMetadata] = [:]  // for editor UI

    init() {
        self.provider = MutableInMemoryProvider(
            name: "registered-variables",
            initialValues: [:]
        )
    }

    func register<T: Codable>(_ variable: ConfigVariable<T>) {
        // Track registration
        registeredKeys.insert(variable.key.description)
        metadata[variable.key.description] = variable.metadata

        // Store value in composed provider
        // (Implementation delegates to MutableInMemoryProvider's storage)
    }

    func isRegistered(_ key: ConfigKey) -> Bool {
        registeredKeys.contains(key.description)
    }

    func metadata(for key: ConfigKey) -> VariableMetadata? {
        metadata[key.description]
    }

    // ConfigProvider conformance delegates to composed provider
    // (snapshot, value lookup, etc.)
}
```

**Design Benefits:**
- Composes `MutableInMemoryProvider` instead of reimplementing storage
- Registration tracking (keys + metadata) stays separate from value storage
- Leverages swift-configuration's existing provider implementation

### Precedence

```
1. Provider A (e.g., remote)
2. Provider B (e.g., JSON file)
3. RegisteredVariablesProvider  ← internal, lowest priority
4. ConfigVariable.fallback      ← inline, used only if all providers fail
```

### Registration Behavior

- **Timing**: Not enforced. Variables can be accessed before registration; telemetry will flag this.
- **Duplicate keys**: Last registration wins; telemetry emitted for duplicate registration.
- **Distributed registration**: Subapps/modules can register their variables at app launch.

### Telemetry

- `DidAccessUnregisteredVariableBusEvent` — key not in `registeredKeys`
- `VariableTypeMismatchBusEvent` — decode failed using accessing type (implies registration/access type mismatch)
- `DuplicateVariableRegistrationBusEvent` — same key registered multiple times

---

## 8. Variable Access Caching (Deferred)

**Note:** Caching has been deferred. May be added later solely for telemetry deduplication.

Original rationale: Caching avoids costly re-decoding and prevents over-emitting telemetry for variable access issues.

### Cache Key

```swift
struct CacheKey: Hashable, Sendable {
    let variableName: String
    let variableType: ObjectIdentifier

    init<T>(_ variable: ConfigVariable<T>) {
        self.variableName = variable.key.description
        self.variableType = ObjectIdentifier(T.self)
    }
}
```

Different types for the same key produce different cache keys — type mismatch won't return stale cached value.

### Cache Entry

```swift
struct CacheEntry: Sendable {
    let value: any Sendable
}
```

Type-erased storage; cast to expected type on access.

### Access Pattern

```swift
func value<T: Codable>(for variable: ConfigVariable<T>) -> T {
    let cacheKey = CacheKey(variable)
    
    // Cache hit
    if let entry = cache[cacheKey],
       let resolved = entry.value as? T {
        return resolved  // No telemetry on cached access
    }
    
    // Cache miss — resolve, emit telemetry, cache
    let resolved = resolveFromProviders(variable)
    cache[cacheKey] = CacheEntry(value: resolved)
    emitAccessTelemetry(variable, resolved)
    return resolved
}
```

### Cache Invalidation

Cache clears when any provider is mutated:
- Remote provider fetch completes (`await provider.fetch()`)
- Local override via Editor UI
- Variable registration
- Any provider snapshot change (via swift-config's `watchSnapshot()`)

### Telemetry Deduplication

- Telemetry emitted once per key per cache lifecycle
- Cached access skips telemetry posting
- After invalidation, next access re-emits telemetry