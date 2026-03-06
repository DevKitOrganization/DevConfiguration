//
//  ConfigVariableReaderArrayTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 2/16/26.
//

import Configuration
import DevFoundation
import DevTesting
import Foundation
import Testing

@testable import DevConfiguration

struct ConfigVariableReaderArrayTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()

    /// A mutable provider for testing.
    let provider = MutableInMemoryProvider(initialValues: [:])

    /// The event bus for testing event posting.
    let eventBus = EventBus()

    /// The reader under test.
    lazy var reader: ConfigVariableReader = {
        ConfigVariableReader(providers: [provider], eventBus: eventBus)
    }()

    /// Sets a value in the provider for the given key with a random `isSecret` flag.
    private mutating func setProviderValue(_ content: ConfigContent, forKey key: ConfigKey) {
        provider.setValue(
            .init(content, isSecret: randomBool()),
            forKey: .init(key)
        )
    }


    // MARK: - [Bool] tests

    @Test
    mutating func valueForBoolArrayReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomBoolArray()
        let defaultValue = randomBoolArray()
        let variable = ConfigVariable<[Bool]>(key: key, defaultValue: defaultValue)
        setProviderValue(.boolArray(expectedValue), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForBoolArrayReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomBoolArray()
        let defaultValue = randomBoolArray()
        let variable = ConfigVariable<[Bool]>(key: key, defaultValue: defaultValue)
        setProviderValue(.boolArray(expectedValue), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func watchValueForBoolArrayReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = randomBoolArray()
        let updatedValue = randomBoolArray()
        let defaultValue = randomBoolArray()
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable<[Bool]>(key: key, defaultValue: defaultValue)
        setProviderValue(.boolArray(initialValue), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.boolArray(updatedValue), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }


    // MARK: - [Int] tests

    @Test
    mutating func valueForIntArrayReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomIntArray()
        let defaultValue = randomIntArray()
        let variable = ConfigVariable<[Int]>(key: key, defaultValue: defaultValue)
        setProviderValue(.intArray(expectedValue), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForIntArrayReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomIntArray()
        let defaultValue = randomIntArray()
        let variable = ConfigVariable<[Int]>(key: key, defaultValue: defaultValue)
        setProviderValue(.intArray(expectedValue), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func watchValueForIntArrayReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = randomIntArray()
        let updatedValue = randomIntArray()
        let defaultValue = randomIntArray()
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable<[Int]>(key: key, defaultValue: defaultValue)
        setProviderValue(.intArray(initialValue), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.intArray(updatedValue), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }


    // MARK: - [Float64] tests

    @Test
    mutating func valueForFloat64ArrayReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomFloat64Array()
        let defaultValue = randomFloat64Array()
        let variable = ConfigVariable<[Float64]>(key: key, defaultValue: defaultValue)
        setProviderValue(.doubleArray(expectedValue), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForFloat64ArrayReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomFloat64Array()
        let defaultValue = randomFloat64Array()
        let variable = ConfigVariable<[Float64]>(key: key, defaultValue: defaultValue)
        setProviderValue(.doubleArray(expectedValue), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func watchValueForFloat64ArrayReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = randomFloat64Array()
        let updatedValue = randomFloat64Array()
        let defaultValue = randomFloat64Array()
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable<[Float64]>(key: key, defaultValue: defaultValue)
        setProviderValue(.doubleArray(initialValue), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.doubleArray(updatedValue), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }


    // MARK: - [String] tests

    @Test
    mutating func valueForStringArrayReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomStringArray()
        let defaultValue = randomStringArray()
        let variable = ConfigVariable<[String]>(key: key, defaultValue: defaultValue)
        setProviderValue(.stringArray(expectedValue), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForStringArrayReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomStringArray()
        let defaultValue = randomStringArray()
        let variable = ConfigVariable<[String]>(key: key, defaultValue: defaultValue)
        setProviderValue(.stringArray(expectedValue), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func watchValueForStringArrayReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = randomStringArray()
        let updatedValue = randomStringArray()
        let defaultValue = randomStringArray()
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable<[String]>(key: key, defaultValue: defaultValue)
        setProviderValue(.stringArray(initialValue), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.stringArray(updatedValue), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }


    // MARK: - [[UInt8]] tests

    @Test
    mutating func valueForByteChunkArrayReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomByteChunkArray()
        let defaultValue = randomByteChunkArray()
        let variable = ConfigVariable<[[UInt8]]>(key: key, defaultValue: defaultValue)
        setProviderValue(.byteChunkArray(expectedValue), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForByteChunkArrayReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomByteChunkArray()
        let defaultValue = randomByteChunkArray()
        let variable = ConfigVariable<[[UInt8]]>(key: key, defaultValue: defaultValue)
        setProviderValue(.byteChunkArray(expectedValue), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func watchValueForByteChunkArrayReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = randomByteChunkArray()
        let updatedValue = randomByteChunkArray()
        let defaultValue = randomByteChunkArray()
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable<[[UInt8]]>(key: key, defaultValue: defaultValue)
        setProviderValue(.byteChunkArray(initialValue), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.byteChunkArray(updatedValue), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }
}
