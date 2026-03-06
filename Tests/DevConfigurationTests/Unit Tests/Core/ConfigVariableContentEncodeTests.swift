//
//  ConfigVariableContentEncodeTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/5/2026.
//

import Configuration
import DevTesting
import Foundation
import Testing

@testable import DevConfiguration

struct ConfigVariableContentEncodeTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    // MARK: - Primitive Content

    @Test
    mutating func encodeBool() throws {
        // set up
        let value = randomBool()

        // exercise
        let content = try ConfigVariableContent<Bool>.bool.encode(value)

        // expect
        #expect(content == .bool(value))
    }


    @Test
    mutating func encodeBoolArray() throws {
        // set up
        let value = randomBoolArray()

        // exercise
        let content = try ConfigVariableContent<[Bool]>.boolArray.encode(value)

        // expect
        #expect(content == .boolArray(value))
    }


    @Test
    mutating func encodeFloat64() throws {
        // set up
        let value = randomFloat64(in: -100_000 ... 100_000)

        // exercise
        let content = try ConfigVariableContent<Float64>.float64.encode(value)

        // expect
        #expect(content == .double(value))
    }


    @Test
    mutating func encodeFloat64Array() throws {
        // set up
        let value = randomFloat64Array()

        // exercise
        let content = try ConfigVariableContent<[Float64]>.float64Array.encode(value)

        // expect
        #expect(content == .doubleArray(value))
    }


    @Test
    mutating func encodeInt() throws {
        // set up
        let value = randomInt(in: .min ... .max)

        // exercise
        let content = try ConfigVariableContent<Int>.int.encode(value)

        // expect
        #expect(content == .int(value))
    }


    @Test
    mutating func encodeIntArray() throws {
        // set up
        let value = randomIntArray()

        // exercise
        let content = try ConfigVariableContent<[Int]>.intArray.encode(value)

        // expect
        #expect(content == .intArray(value))
    }


    @Test
    mutating func encodeString() throws {
        // set up
        let value = randomAlphanumericString()

        // exercise
        let content = try ConfigVariableContent<String>.string.encode(value)

        // expect
        #expect(content == .string(value))
    }


    @Test
    mutating func encodeStringArray() throws {
        // set up
        let value = randomStringArray()

        // exercise
        let content = try ConfigVariableContent<[String]>.stringArray.encode(value)

        // expect
        #expect(content == .stringArray(value))
    }


    @Test
    mutating func encodeBytes() throws {
        // set up
        let value = randomBytes()

        // exercise
        let content = try ConfigVariableContent<[UInt8]>.bytes.encode(value)

        // expect
        #expect(content == .bytes(value))
    }


    @Test
    mutating func encodeByteChunkArray() throws {
        // set up
        let value = randomByteChunkArray()

        // exercise
        let content = try ConfigVariableContent<[[UInt8]]>.byteChunkArray.encode(value)

        // expect
        #expect(content == .byteChunkArray(value))
    }


    // MARK: - String-Convertible Content

    @Test
    mutating func encodeRawRepresentableString() throws {
        // set up
        let value = MockStringEnum.allCases.randomElement(using: &randomNumberGenerator)!

        // exercise
        let content = try ConfigVariableContent<MockStringEnum>.rawRepresentableString().encode(value)

        // expect
        #expect(content == .string(value.rawValue))
    }


    @Test
    mutating func encodeRawRepresentableStringArray() throws {
        // set up
        let value = Array(count: randomInt(in: 1 ... 5)) {
            MockStringEnum.allCases.randomElement(using: &randomNumberGenerator)!
        }

        // exercise
        let content = try ConfigVariableContent<[MockStringEnum]>.rawRepresentableStringArray().encode(value)

        // expect
        #expect(content == .stringArray(value.map(\.rawValue)))
    }


    @Test
    mutating func encodeExpressibleByConfigString() throws {
        // set up
        let value = MockConfigStringValue(configString: randomAlphanumericString())!

        // exercise
        let content = try ConfigVariableContent<MockConfigStringValue>.expressibleByConfigString().encode(value)

        // expect
        #expect(content == .string(value.description))
    }


    @Test
    mutating func encodeExpressibleByConfigStringArray() throws {
        // set up
        let value = Array(count: randomInt(in: 1 ... 5)) {
            MockConfigStringValue(configString: randomAlphanumericString())!
        }

        // exercise
        let content =
            try ConfigVariableContent<[MockConfigStringValue]>.expressibleByConfigStringArray().encode(value)

        // expect
        #expect(content == .stringArray(value.map(\.description)))
    }


    // MARK: - Int-Convertible Content

    @Test
    mutating func encodeRawRepresentableInt() throws {
        // set up
        let value = MockIntEnum.allCases.randomElement(using: &randomNumberGenerator)!

        // exercise
        let content = try ConfigVariableContent<MockIntEnum>.rawRepresentableInt().encode(value)

        // expect
        #expect(content == .int(value.rawValue))
    }


    @Test
    mutating func encodeRawRepresentableIntArray() throws {
        // set up
        let value = Array(count: randomInt(in: 1 ... 5)) {
            MockIntEnum.allCases.randomElement(using: &randomNumberGenerator)!
        }

        // exercise
        let content = try ConfigVariableContent<[MockIntEnum]>.rawRepresentableIntArray().encode(value)

        // expect
        #expect(content == .intArray(value.map(\.rawValue)))
    }


    @Test
    mutating func encodeExpressibleByConfigInt() throws {
        // set up
        let value = MockConfigIntValue(configInt: randomInt(in: .min ... .max))!

        // exercise
        let content = try ConfigVariableContent<MockConfigIntValue>.expressibleByConfigInt().encode(value)

        // expect
        #expect(content == .int(value.configInt))
    }


    @Test
    mutating func encodeExpressibleByConfigIntArray() throws {
        // set up
        let value = Array(count: randomInt(in: 1 ... 5)) {
            MockConfigIntValue(configInt: randomInt(in: .min ... .max))!
        }

        // exercise
        let content =
            try ConfigVariableContent<[MockConfigIntValue]>.expressibleByConfigIntArray().encode(value)

        // expect
        #expect(content == .intArray(value.map(\.configInt)))
    }


    // MARK: - Codable Content

    @Test
    mutating func encodeJSONWithStringRepresentation() throws {
        // set up
        let value = MockCodableConfig(variant: randomAlphanumericString(), count: randomInt(in: 0 ... 1000))

        // exercise
        let content = try ConfigVariableContent<MockCodableConfig>.json(representation: .string()).encode(value)

        // expect — decode the encoded string back to verify round-trip correctness
        guard case .string(let jsonString) = content else {
            Issue.record("Expected .string content, got \(content)")
            return
        }
        let decoded = try JSONDecoder().decode(MockCodableConfig.self, from: Data(jsonString.utf8))
        #expect(decoded == value)
    }


    @Test
    mutating func encodeJSONWithDataRepresentation() throws {
        // set up
        let value = MockCodableConfig(variant: randomAlphanumericString(), count: randomInt(in: 0 ... 1000))

        // exercise
        let content = try ConfigVariableContent<MockCodableConfig>.json(representation: .data).encode(value)

        // expect — decode the encoded bytes back to verify round-trip correctness
        guard case .bytes(let bytes) = content else {
            Issue.record("Expected .bytes content, got \(content)")
            return
        }
        let decoded = try JSONDecoder().decode(MockCodableConfig.self, from: Data(bytes))
        #expect(decoded == value)
    }


    @Test
    mutating func encodePropertyListWithExplicitEncoder() throws {
        // set up
        let value = MockCodableConfig(variant: randomAlphanumericString(), count: randomInt(in: 0 ... 1000))
        let encoder = PropertyListEncoder()

        // exercise
        let content = try ConfigVariableContent<MockCodableConfig>.propertyList(encoder: encoder).encode(value)

        // expect — decode the encoded bytes back to verify round-trip correctness
        guard case .bytes(let bytes) = content else {
            Issue.record("Expected .bytes content, got \(content)")
            return
        }
        let decoded = try PropertyListDecoder().decode(MockCodableConfig.self, from: Data(bytes))
        #expect(decoded == value)
    }
}
