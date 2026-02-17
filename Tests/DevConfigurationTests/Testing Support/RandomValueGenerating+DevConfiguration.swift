//
//  RandomValueGenerating+DevConfiguration.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 2/16/2026.
//

import Configuration
import DevConfiguration
import DevTesting
import Foundation

extension RandomValueGenerating {
    mutating func randomAbsoluteConfigKey() -> AbsoluteConfigKey {
        return AbsoluteConfigKey(randomConfigKey())
    }


    mutating func randomAccessEvent(
        key: AbsoluteConfigKey? = nil,
        result: Result<ConfigValue?, any Error>? = nil,
        providerResults: [AccessEvent.ProviderResult]? = nil
    ) -> AccessEvent {
        return AccessEvent(
            metadata: AccessEvent.Metadata(
                accessKind: randomElement(in: [.get, .fetch, .watch])!,
                key: key ?? randomAbsoluteConfigKey(),
                valueType: .string,
                sourceLocation: AccessEvent.Metadata.SourceLocation(
                    fileID: randomAlphanumericString(),
                    line: random(UInt.self, in: .min ... .max)
                ),
                accessTimestamp: randomDate()
            ),
            providerResults: providerResults ?? [randomProviderResult()],
            result: result ?? .success(randomConfigValue())
        )
    }


    mutating func randomBoolArray() -> [Bool] {
        return Array(count: randomInt(in: 0 ... 5)) { randomBool() }
    }


    mutating func randomByteChunkArray() -> [[UInt8]] {
        return Array(count: randomInt(in: 0 ... 5)) { randomBytes() }
    }


    mutating func randomBytes() -> [UInt8] {
        return Array(count: randomInt(in: 0 ... 5)) { random(UInt8.self, in: .min ... .max) }
    }


    mutating func randomConfigContent() -> ConfigContent {
        switch randomInt(in: 0 ... 9) {
        case 0:
            .string(randomAlphanumericString())
        case 1:
            .int(randomInt(in: .min ... .max))
        case 2:
            .double(randomFloat64(in: -100_000 ... 100_000))
        case 3:
            .bool(randomBool())
        case 4:
            .bytes(randomBytes())
        case 5:
            .stringArray(randomStringArray())
        case 6:
            .intArray(randomIntArray())
        case 7:
            .doubleArray(randomFloat64Array())
        case 8:
            .boolArray(randomBoolArray())
        default:
            .byteChunkArray(randomByteChunkArray())
        }
    }


    mutating func randomConfigKey() -> ConfigKey {
        let components = Array(count: randomInt(in: 1 ... 5)) { randomAlphanumericString() }
        return ConfigKey(components)
    }


    mutating func randomConfigValue() -> ConfigValue {
        return ConfigValue(randomConfigContent(), isSecret: randomBool())
    }


    mutating func randomConfigVariableSecrecy() -> ConfigVariableSecrecy {
        return randomCase(of: ConfigVariableSecrecy.self)!
    }


    mutating func randomError() -> MockError {
        return MockError(id: randomAlphanumericString())
    }


    mutating func randomFloat64Array() -> [Float64] {
        return Array(count: randomInt(in: 0 ... 5)) { randomFloat64(in: -100_000 ... 100_000) }
    }


    mutating func randomIntArray() -> [Int] {
        return Array(count: randomInt(in: 0 ... 5)) { randomInt(in: .min ... .max) }
    }


    mutating func randomProviderResult(
        providerName: String? = nil,
        result: Result<LookupResult, any Error>? = nil
    ) -> AccessEvent.ProviderResult {
        let providerName = providerName ?? randomAlphanumericString()
        let result = result ?? .success(.init(encodedKey: randomAlphanumericString(), value: randomConfigValue()))
        return AccessEvent.ProviderResult(providerName: providerName, result: result)
    }


    mutating func randomStringArray() -> [String] {
        return Array(count: randomInt(in: 0 ... 5)) { randomAlphanumericString() }
    }
}
