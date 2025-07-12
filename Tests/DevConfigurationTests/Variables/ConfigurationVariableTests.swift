//
//  ConfigurationVariableTests.swift
//  DevConfigurationTests
//
//  Created by Duncan Lewis on 7/12/25.
//

import DevTesting
import Foundation
import Testing

@testable import DevConfiguration

struct ConfigurationVariableTests: RandomValueGenerating {
    var randomNumberGenerator = SeedableRandomNumberGenerator()

    // MARK: - Test Init

    @Test
    mutating func testInitWithStringName() {
        let expectedName = randomAlphanumericString()
        let expectedFallbackValue = randomAlphanumericString()

        let variable = ConfigurationVariable(
            name: expectedName,
            fallbackValue: expectedFallbackValue
        )

        #expect(variable.name.rawValue == expectedName)
        #expect(variable.fallbackValue == expectedFallbackValue)
    }


    @Test
    mutating func testInitWithVariableName() {
        let expectedName = VariableName(randomAlphanumericString())
        let expectedFallbackValue = randomAlphanumericString()

        let variable = ConfigurationVariable(
            name: expectedName,
            fallbackValue: expectedFallbackValue
        )

        #expect(variable.name == expectedName)
        #expect(variable.fallbackValue == expectedFallbackValue)
    }


    @Test
    mutating func testInitWithDifferentValueTypes() {
        // Test Boolean
        let boolVariable = ConfigurationVariable(
            name: "boolVar",
            fallbackValue: true
        )
        #expect(boolVariable.fallbackValue == true)

        // Test Int
        let intVariable = ConfigurationVariable(
            name: "intVar",
            fallbackValue: 42
        )
        #expect(intVariable.fallbackValue == 42)

        // Test Double
        let doubleVariable = ConfigurationVariable(
            name: "doubleVar",
            fallbackValue: 3.14
        )
        #expect(doubleVariable.fallbackValue == 3.14)

        // Test String
        let stringVariable = ConfigurationVariable(
            name: "stringVar",
            fallbackValue: "test"
        )
        #expect(stringVariable.fallbackValue == "test")
    }


    // MARK: - Test Metadata

    @Test
    mutating func testMetadataReadsAndWritesValue() {
        var variable = ConfigurationVariable(
            name: randomAlphanumericString(),
            fallbackValue: randomAlphanumericString()
        )

        for _ in 0 ... random(Int.self, in: 3 ... 5) {
            let expectedMetadataValue = randomAlphanumericString()
            variable = variable.metadata(\.testMetadata, expectedMetadataValue)

            #expect(variable.testMetadata == expectedMetadataValue)
        }
    }


    @Test
    mutating func testMetadataSubscriptReadsAndWritesValue() {
        var variable = ConfigurationVariable(
            name: randomAlphanumericString(),
            fallbackValue: randomAlphanumericString()
        )

        for _ in 0 ... random(Int.self, in: 3 ... 5) {
            let expectedMetadataValue = randomAlphanumericString()
            variable.testMetadata = expectedMetadataValue

            #expect(variable.testMetadata == expectedMetadataValue)
        }
    }


    @Test
    mutating func testMetadataFunctionalChaining() {
        let variable = ConfigurationVariable(
            name: randomAlphanumericString(),
            fallbackValue: randomAlphanumericString()
        )

        let expectedTestValue = randomAlphanumericString()
        let expectedNumberValue = random(Int.self, in: 0 ... 100)

        let updatedVariable =
            variable
            .metadata(\.testMetadata, expectedTestValue)
            .metadata(\.numberMetadata, expectedNumberValue)

        #expect(updatedVariable.testMetadata == expectedTestValue)
        #expect(updatedVariable.numberMetadata == expectedNumberValue)
    }


    @Test
    mutating func testMetadataPreservesOriginalVariable() {
        let originalVariable = ConfigurationVariable(
            name: randomAlphanumericString(),
            fallbackValue: randomAlphanumericString()
        )

        let expectedValue = randomAlphanumericString()
        let updatedVariable = originalVariable.metadata(\.testMetadata, expectedValue)

        // Original should not be modified
        #expect(originalVariable.testMetadata == TestMetadataKey.defaultValue)

        // Updated should have the new value
        #expect(updatedVariable.testMetadata == expectedValue)
    }


    // MARK: - Test Equatable

    @Test
    mutating func testEquatable() {
        let name = randomAlphanumericString()
        let fallbackValue = randomAlphanumericString()
        let metadataValue = randomAlphanumericString()

        let variable1 = ConfigurationVariable(name: name, fallbackValue: fallbackValue)
            .metadata(\.testMetadata, metadataValue)

        let variable2 = ConfigurationVariable(name: name, fallbackValue: fallbackValue)
            .metadata(\.testMetadata, metadataValue)

        let variable3 = ConfigurationVariable(name: randomAlphanumericString(), fallbackValue: fallbackValue)
            .metadata(\.testMetadata, metadataValue)

        #expect(variable1 == variable2)
        #expect(variable1 != variable3)
    }


    // MARK: - Test Codable (TODO: Implement when needed)


    // MARK: - Test Sendable

    @Test
    mutating func testSendable() {
        let variable = ConfigurationVariable(
            name: randomAlphanumericString(),
            fallbackValue: randomAlphanumericString()
        )

        // Should compile without warnings - Sendable conformance
        Task {
            let _ = variable
        }
    }
}

// MARK: - Test Metadata Extensions

extension VariableMetadata {
    fileprivate var testMetadata: String {
        get { self[TestMetadataKey.self] }
        set { self[TestMetadataKey.self] = newValue }
    }

    fileprivate var numberMetadata: Int {
        get { self[NumberMetadataKey.self] }
        set { self[NumberMetadataKey.self] = newValue }
    }
}


private struct TestMetadataKey: VariableMetadataKey {
    typealias Value = String

    static var defaultValue: String {
        return "defaultTest"
    }

    static var keyDisplayText: String {
        return "Test Metadata"
    }

    static func displayText(for value: String) -> String? {
        return value
    }
}


private struct NumberMetadataKey: VariableMetadataKey {
    typealias Value = Int

    static var defaultValue: Int {
        return 0
    }

    static var keyDisplayText: String {
        return "Number Metadata"
    }

    static func displayText(for value: Int) -> String? {
        return String(value)
    }
}
