# StructuredConfigReading Test Plan

Created by Duncan Lewis, 2026-01-07

## Notes

`StructuredConfigReading` is a protocol with no implementation or testable behavior.
Testing will be performed through `StructuredConfigReader` which implements this protocol.

All 8 method overloads will be tested as part of the StructuredConfigReader test suite:
- `value(for: ConfigVariable<Bool>) -> Bool`
- `value(for: ConfigVariable<String>) -> String`
- `value(for: ConfigVariable<Int>) -> Int`
- `value(for: ConfigVariable<Float64>) -> Float64`
- `value(for: ConfigVariable<[Bool]>) -> [Bool]`
- `value(for: ConfigVariable<[String]>) -> [String]`
- `value(for: ConfigVariable<[Int]>) -> [Int]`
- `value(for: ConfigVariable<[Float64]>) -> [Float64]`
