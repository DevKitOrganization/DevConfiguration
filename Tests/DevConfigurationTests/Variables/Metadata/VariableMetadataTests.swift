//
//  VariableMetadataTests.swift
//  DevConfigurationTests
//
//  Created by Duncan Lewis on 7/12/25.
//

import DevTesting
import Foundation
import Testing

@testable import DevConfiguration

struct VariableMetadataTests: RandomValueGenerating {
    var randomNumberGenerator = SeedableRandomNumberGenerator()

    @Test
    mutating func testVariableMetadataDisplayTextEntriesEmptyByDefault() {
        let metadata = VariableMetadata()
        #expect(metadata.displayTextEntries == [])
    }

    @Test
    mutating func testVariableMetadataReturnsDefaultForKey() {
        let metadata = VariableMetadata()

        // metadata with no values set should return default for a key
        #expect(metadata[MockVariableMetadataKey.self] == MockVariableMetadataKey.defaultValue)
    }

    @Test
    mutating func testVariableMetadataReturnsValueForKey() {
        var metadata = VariableMetadata()
        let value = random(Int.self, in: Int.min ... Int.max)
        let expectedDisplayValue = randomAlphanumericString()

        MockVariableMetadataKey.stubDisplayTextForValue = expectedDisplayValue
        metadata[MockVariableMetadataKey.self] = value

        let displayTextEntry = VariableMetadata.DisplayText(
            key: MockVariableMetadataKey.keyDisplayText,
            value: expectedDisplayValue
        )

        #expect(metadata.displayTextEntries == [displayTextEntry])
    }

    @Test
    mutating func testVariableMetadataKeyDefaultDisplayText_forRawRepresentableString() {
        let value = randomCase(of: MockStringEnumVariableMetadataValue.self)!

        #expect(
            MockStringEnumVariableMetadataKey.displayText(for: value) == value.rawValue
        )
    }

    @Test
    mutating func testVariableMetadataKeyDefaultDisplayText_forOptionalRawRepresentableString() {
        #expect(MockOptionalStringEnumVariableMetadataKey.displayText(for: nil) == nil)

        let value = randomCase(of: MockStringEnumVariableMetadataValue.self)!
        #expect(
            MockOptionalStringEnumVariableMetadataKey.displayText(for: value) == value.rawValue
        )
    }

    @Test
    mutating func testVariableMetadataKeyDefaultDisplayText_forOptional() {
        #expect(MockOptionalUUIDVariableMetadataKey.displayText(for: nil) == nil)

        let value = randomUUID()
        #expect(
            MockOptionalUUIDVariableMetadataKey.displayText(for: value) == String(describing: value)
        )
    }

    @Test
    mutating func testVariableMetadataKeyDefaultDisplayText_forAnyType() {
        let value = randomUUID()
        #expect(
            MockUUIDVariableMetadataKey.displayText(for: value) == String(describing: value)
        )
    }

    @Test
    mutating func testVariableMetadataEquatable() {
        var metadata1 = VariableMetadata()
        var metadata2 = VariableMetadata()

        // Empty metadata should be equal
        #expect(metadata1 == metadata2)

        // Same values should be equal
        let value = random(Int.self, in: 0 ... 100)
        metadata1[MockVariableMetadataKey.self] = value
        metadata2[MockVariableMetadataKey.self] = value
        #expect(metadata1 == metadata2)

        // Different values should not be equal
        metadata2[MockVariableMetadataKey.self] = random(Int.self, in: 200 ... 300)
        #expect(metadata1 != metadata2)
    }

    @Test
    mutating func testVariableMetadataHashable() {
        var metadata1 = VariableMetadata()
        var metadata2 = VariableMetadata()

        let value = random(Int.self, in: 0 ... 100)
        metadata1[MockVariableMetadataKey.self] = value
        metadata2[MockVariableMetadataKey.self] = value

        #expect(metadata1.hashValue == metadata2.hashValue)
    }
}

// MARK: - Test Mock Types

private struct MockVariableMetadataKey: VariableMetadataKey {
    static var defaultValue: Int {
        return 0
    }

    static var keyDisplayText: String {
        return "MockVariableMetadataKey"
    }

    // Display value will equal the value for tests.
    nonisolated(unsafe)
        static var stubDisplayTextForValue: String? = ""

    static func displayText(for value: Int) -> String? {
        return stubDisplayTextForValue
    }
}

private enum MockStringEnumVariableMetadataValue: String, CaseIterable {
    case option1 = "option1"
    case option2 = "option2"
    case option3 = "option3"
}

private struct MockStringEnumVariableMetadataKey: VariableMetadataKey {
    static var defaultValue: MockStringEnumVariableMetadataValue {
        return .option1
    }

    static var keyDisplayText: String {
        return "MockStringEnumVariableMetadataKey"
    }
}

private struct MockOptionalStringEnumVariableMetadataKey: VariableMetadataKey {
    static var defaultValue: MockStringEnumVariableMetadataValue? {
        return nil
    }

    static var keyDisplayText: String {
        return "MockOptionalStringEnumVariableMetadataKey"
    }
}

private struct MockUUIDVariableMetadataKey: VariableMetadataKey {
    static var defaultValue: UUID {
        return UUID()
    }

    static var keyDisplayText: String {
        return "MockUUIDVariableMetadataKey"
    }
}

private struct MockOptionalUUIDVariableMetadataKey: VariableMetadataKey {
    static var defaultValue: UUID? {
        return nil
    }

    static var keyDisplayText: String {
        return "MockOptionalUUIDVariableMetadataKey"
    }
}
