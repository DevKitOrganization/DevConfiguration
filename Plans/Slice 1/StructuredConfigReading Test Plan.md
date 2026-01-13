# StructuredConfigReading Test Plan

Created by Duncan Lewis, 2026-01-07

## Notes

The `StructuredConfigReading` protocol defines the interface for configuration reading. It does not implement the core `value(for:)` methods (tested via StructuredConfigReader), but it provides default subscript implementations via a protocol extension that can be tested independently.

### Protocol Requirements (tested via StructuredConfigReader)

The 8 `value(for:)` method overloads will be tested through `StructuredConfigReader`:
- `value(for: ConfigVariable<Bool>) -> Bool`
- `value(for: ConfigVariable<String>) -> String`
- `value(for: ConfigVariable<Int>) -> Int`
- `value(for: ConfigVariable<Float64>) -> Float64`
- `value(for: ConfigVariable<[Bool]>) -> [Bool]`
- `value(for: ConfigVariable<[String]>) -> [String]`
- `value(for: ConfigVariable<[Int]>) -> [Int]`
- `value(for: ConfigVariable<[Float64]>) -> [Float64]`

### Protocol Extension (testable separately)

The protocol extension provides default subscript implementations that delegate to `value(for:)`. These can be tested independently using a mock conforming type.

## StructuredConfigReading Extension Tests

### Subscript Access - Bool
- subscript(variable:) delegates to value(for:) for Bool

### Subscript Access - String
- subscript(variable:) delegates to value(for:) for String

### Subscript Access - Int
- subscript(variable:) delegates to value(for:) for Int

### Subscript Access - Float64
- subscript(variable:) delegates to value(for:) for Float64

### Subscript Access - [Bool]
- subscript(variable:) delegates to value(for:) for [Bool]

### Subscript Access - [String]
- subscript(variable:) delegates to value(for:) for [String]

### Subscript Access - [Int]
- subscript(variable:) delegates to value(for:) for [Int]

### Subscript Access - [Float64]
- subscript(variable:) delegates to value(for:) for [Float64]
