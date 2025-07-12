//
//  VariableNameTests.swift
//  DevConfigurationTests
//
//  Created by Duncan Lewis on 7/12/25.
//

import DevTesting
import Foundation
import Testing

@testable import DevConfiguration

struct VariableNameTests: RandomValueGenerating {
    var randomNumberGenerator = SeedableRandomNumberGenerator()


    @Test
    mutating func testInitWithString() {
        let expectedName = randomAlphanumericString()

        let variableName = VariableName(expectedName)

        #expect(variableName.rawValue == expectedName)
    }


    @Test
    mutating func testRawRepresentableInit() {
        let expectedName = randomAlphanumericString()

        let variableName = VariableName(rawValue: expectedName)

        #expect(variableName?.rawValue == expectedName)
    }


    @Test
    mutating func testStringLiteralInit() {
        let variableName: VariableName = "testVariable"

        #expect(variableName.rawValue == "testVariable")
    }


    @Test
    mutating func testDescription() {
        let expectedName = randomAlphanumericString()
        let variableName = VariableName(expectedName)

        #expect(variableName.description == expectedName)
    }


    @Test
    mutating func testEquatable() {
        let name = randomAlphanumericString()
        let variableName1 = VariableName(name)
        let variableName2 = VariableName(name)
        let variableName3 = VariableName(randomAlphanumericString())

        #expect(variableName1 == variableName2)
        #expect(variableName1 != variableName3)
    }


    @Test
    mutating func testHashable() {
        let name = randomAlphanumericString()
        let variableName1 = VariableName(name)
        let variableName2 = VariableName(name)

        #expect(variableName1.hashValue == variableName2.hashValue)
    }


    @Test
    mutating func testCodable() throws {
        let originalName = randomAlphanumericString()
        let variableName = VariableName(originalName)

        let encoded = try JSONEncoder().encode(variableName)
        let decoded = try JSONDecoder().decode(VariableName.self, from: encoded)

        #expect(decoded.rawValue == originalName)
    }
}
