//
//  ConfigContent+AdditionsTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/7/2026.
//

import Configuration
import DevTesting
import Foundation
import Testing

@testable import DevConfiguration

struct ConfigContent_AdditionsTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test(
        arguments: [
            (ConfigContent.string("hello"), ConfigType.string),
            (.int(42), .int),
            (.double(3.14), .double),
            (.bool(true), .bool),
            (.bytes([1, 2, 3]), .bytes),
            (.stringArray(["a", "b"]), .stringArray),
            (.intArray([1, 2]), .intArray),
            (.doubleArray([1.0, 2.0]), .doubleArray),
            (.boolArray([true, false]), .boolArray),
            (.byteChunkArray([[1], [2]]), .byteChunkArray),
        ]
    )
    func configTypeReturnsCorrectType(content: ConfigContent, expectedType: ConfigType) {
        #expect(content.configType == expectedType)
    }


    @Test(
        arguments: [
            (ConfigContent.bool(true), "Bool"),
            (.int(42), "Int"),
            (.double(3.14), "Float64"),
            (.string("hello"), "String"),
            (.bytes([1, 2, 3]), "Data"),
            (.boolArray([true, false]), "[Bool]"),
            (.intArray([1, 2]), "[Int]"),
            (.doubleArray([1.0, 2.0]), "[Float64]"),
            (.stringArray(["a", "b"]), "[String]"),
            (.byteChunkArray([[1], [2]]), "[Data]"),
        ]
    )
    func typeDisplayNameReturnsCorrectName(content: ConfigContent, expectedName: String) {
        #expect(content.typeDisplayName == expectedName)
    }


    @Test(
        arguments: [
            ConfigContent.string("hello"),
            .int(42),
            .double(3.14),
            .bool(true),
            .bytes([0, 255, 128]),
            .stringArray(["a", "b", "c"]),
            .intArray([1, 2, 3]),
            .doubleArray([1.5, 2.5]),
            .boolArray([true, false, true]),
            .byteChunkArray([[1, 2], [3, 4]]),
        ]
    )
    func codableRoundTripsContent(content: ConfigContent) throws {
        // exercise
        let data = try JSONEncoder().encode(content)
        let decoded = try JSONDecoder().decode(ConfigContent.self, from: data)

        // expect
        #expect(decoded == content)
    }


    // MARK: - editableString

    @Test(
        arguments: [
            ConfigContent.bool(true),
            .int(42),
            .double(3.14),
            .string("hello"),
            .bytes([1, 2, 3]),
        ]
    )
    func editableStringMatchesDisplayStringForScalars(content: ConfigContent) {
        #expect(content.editableString == content.displayString)
    }


    @Test
    func editableStringReturnsByteChunkArrayAsDisplayString() {
        let content = ConfigContent.byteChunkArray([[1, 2], [3, 4]])
        #expect(content.editableString == content.displayString)
    }


    @Test
    func editableStringReturnsNewlineSeparatedBoolArray() {
        #expect(ConfigContent.boolArray([true, false, true]).editableString == "true\nfalse\ntrue")
    }


    @Test
    func editableStringReturnsNewlineSeparatedIntArray() {
        #expect(ConfigContent.intArray([1, 2, 3]).editableString == "1\n2\n3")
    }


    @Test
    func editableStringReturnsNewlineSeparatedDoubleArray() {
        #expect(ConfigContent.doubleArray([1.5, 2.5]).editableString == "1.5\n2.5")
    }


    @Test
    func editableStringReturnsNewlineSeparatedStringArray() {
        #expect(ConfigContent.stringArray(["a", "b", "c"]).editableString == "a\nb\nc")
    }


    // MARK: - Codable

    @Test
    func decodingUnknownTypeThrows() throws {
        // set up
        let json = #"{"type":"unknown","value":"test"}"#
        let data = Data(json.utf8)

        // expect
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(ConfigContent.self, from: data)
        }
    }
}
