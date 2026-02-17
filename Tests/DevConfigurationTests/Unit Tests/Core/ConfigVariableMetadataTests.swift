//
//  ConfigVariableMetadataTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 2/17/2026.
//

import DevTesting
import Testing

@testable import DevConfiguration

struct ConfigVariableMetadataTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    // MARK: - subscript

    @Test
    mutating func subscriptGetReturnsDefaultValueWhenNotSetAndStoresAndRetrievesSetValue() {
        // set up the test by creating empty metadata
        var metadata = ConfigVariableMetadata()

        // expect that unset key returns default value
        #expect(metadata[IntMetadataKey.self] == 0)
        #expect(metadata[StringMetadataKey.self] == nil)

        // exercise the test by setting values
        let intValue = randomInt(in: .min ... .max)
        let stringValue = randomAlphanumericString()
        metadata[IntMetadataKey.self] = intValue
        metadata[StringMetadataKey.self] = stringValue

        // expect that values are stored and retrieved correctly
        #expect(metadata[IntMetadataKey.self] == intValue)
        #expect(metadata[StringMetadataKey.self] == stringValue)
    }


    // MARK: - displayTextEntries

    @Test
    mutating func subscriptSetterUpdatesDisplayTextEntries() {
        // set up the test by creating metadata and setting values
        var metadata = ConfigVariableMetadata()
        let intValue = randomInt(in: .min ... .max)
        let stringValue = randomAlphanumericString()

        // expect that initially displayTextEntries is empty
        #expect(metadata.displayTextEntries.isEmpty)

        // exercise the test by setting metadata values
        metadata[IntMetadataKey.self] = intValue
        metadata[StringMetadataKey.self] = stringValue

        // expect that displayTextEntries contains both entries
        let entries = metadata.displayTextEntries
        #expect(entries.count == 2)
        #expect(entries.contains(.init(key: "IntKey", value: String(intValue))))
        #expect(entries.contains(.init(key: "StringKey", value: stringValue)))
    }


    @Test
    mutating func multipleMetadataKeysWorkIndependently() {
        // set up the test by creating metadata with initial values
        var metadata = ConfigVariableMetadata()
        let intValue1 = randomInt(in: .min ... .max)
        let stringValue1 = randomAlphanumericString()
        metadata[IntMetadataKey.self] = intValue1
        metadata[StringMetadataKey.self] = stringValue1

        // exercise the test by updating one key
        let intValue2 = randomInt(in: .min ... .max)
        metadata[IntMetadataKey.self] = intValue2

        // expect that the updated key has the new value and the other key is unchanged
        #expect(metadata[IntMetadataKey.self] == intValue2)
        #expect(metadata[StringMetadataKey.self] == stringValue1)
    }


    // MARK: - displayText(for:)

    @Test
    mutating func displayTextForRawRepresentableReturnsRawValue() {
        let value = randomCase(of: MetadataEnum.self)!
        #expect(EnumMetadataKey.displayText(for: value) == value.rawValue)
    }


    @Test
    func displayTextForOptionalReturnsNilWhenValueIsNil() {
        #expect(OptionalIntMetadataKey.displayText(for: nil) == nil)
    }


    @Test
    mutating func displayTextForOptionalReturnsDescriptionWhenValueIsNotNil() {
        let int = randomInt(in: .min ... .max)
        #expect(OptionalIntMetadataKey.displayText(for: int) == String(int))
    }


    @Test
    mutating func displayTextForOptionalRawRepresentableReturnsRawValueWhenNotNil() {
        let value = randomCase(of: MetadataEnum.self)!
        #expect(OptionalEnumMetadataKey.displayText(for: .valueB) == value.rawValue)
    }


    @Test
    func displayTextForOptionalRawRepresentableReturnsNilWhenValueIsNil() {
        #expect(OptionalEnumMetadataKey.displayText(for: nil) == nil)
    }
}


// MARK: - Test Metadata Keys

private enum MetadataEnum: String, CaseIterable, Sendable {
    case valueA
    case valueB
}


private struct EnumMetadataKey: ConfigVariableMetadataKey {
    static let defaultValue = MetadataEnum.valueA
    static let keyDisplayText = "EnumKey"
}


private struct IntMetadataKey: ConfigVariableMetadataKey {
    static let defaultValue = 0
    static let keyDisplayText = "IntKey"
}


private struct OptionalEnumMetadataKey: ConfigVariableMetadataKey {
    static let defaultValue: MetadataEnum? = nil
    static let keyDisplayText = "OptionalEnumKey"
}


private struct OptionalIntMetadataKey: ConfigVariableMetadataKey {
    static let defaultValue: Int? = nil
    static let keyDisplayText = "OptionalIntKey"
}


private struct StringMetadataKey: ConfigVariableMetadataKey {
    static let defaultValue: String? = nil
    static let keyDisplayText = "StringKey"
}
