//
//  ConfigVariableReaderScalarTests.swift
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

struct ConfigVariableReaderScalarTests: RandomValueGenerating {
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


    // MARK: - Bool tests

    @Test
    mutating func valueForBoolReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomBool()
        let defaultValue = !expectedValue
        let variable = ConfigVariable<Bool>(key: key, defaultValue: defaultValue)
        setProviderValue(.bool(expectedValue), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func valueForBoolReturnsDefaultWhenKeyNotFound() {
        // set up
        let key = randomConfigKey()
        let defaultValue = randomBool()
        let variable = ConfigVariable<Bool>(key: key, defaultValue: defaultValue)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == defaultValue)
    }


    @Test
    mutating func fetchValueForBoolReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomBool()
        let defaultValue = !expectedValue
        let variable = ConfigVariable<Bool>(key: key, defaultValue: defaultValue)
        setProviderValue(.bool(expectedValue), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForBoolReturnsDefaultWhenKeyNotFound() async throws {
        // set up
        let key = randomConfigKey()
        let defaultValue = randomBool()
        let variable = ConfigVariable<Bool>(key: key, defaultValue: defaultValue)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == defaultValue)
    }


    @Test
    mutating func watchValueForBoolReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = randomBool()
        let updatedValue = !initialValue
        let defaultValue = randomBool()
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable<Bool>(key: key, defaultValue: defaultValue)
        setProviderValue(.bool(initialValue), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.bool(updatedValue), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }


    @Test
    mutating func subscriptBoolReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomBool()
        let defaultValue = !expectedValue
        let variable = ConfigVariable<Bool>(key: key, defaultValue: defaultValue)
        setProviderValue(.bool(expectedValue), forKey: key)

        // exercise
        let result = reader[variable]

        // expect
        #expect(result == expectedValue)
    }


    // MARK: - Int tests

    @Test
    mutating func valueForIntReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomInt(in: .min ... .max)
        let defaultValue = randomInt(in: .min ... .max)
        let variable = ConfigVariable<Int>(key: key, defaultValue: defaultValue)
        setProviderValue(.int(expectedValue), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForIntReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomInt(in: .min ... .max)
        let defaultValue = randomInt(in: .min ... .max)
        let variable = ConfigVariable<Int>(key: key, defaultValue: defaultValue)
        setProviderValue(.int(expectedValue), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func watchValueForIntReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = randomInt(in: .min ... .max)
        let updatedValue = randomInt(in: .min ... .max)
        let defaultValue = randomInt(in: .min ... .max)
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable<Int>(key: key, defaultValue: defaultValue)
        setProviderValue(.int(initialValue), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.int(updatedValue), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }


    // MARK: - Float64 tests

    @Test
    mutating func valueForFloat64ReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomFloat64(in: -100_000 ... 100_000)
        let defaultValue = randomFloat64(in: -100_000 ... 100_000)
        let variable = ConfigVariable<Float64>(key: key, defaultValue: defaultValue)
        setProviderValue(.double(expectedValue), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForFloat64ReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomFloat64(in: -100_000 ... 100_000)
        let defaultValue = randomFloat64(in: -100_000 ... 100_000)
        let variable = ConfigVariable<Float64>(key: key, defaultValue: defaultValue)
        setProviderValue(.double(expectedValue), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func watchValueForFloat64ReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = randomFloat64(in: -100_000 ... 100_000)
        let updatedValue = randomFloat64(in: -100_000 ... 100_000)
        let defaultValue = randomFloat64(in: -100_000 ... 100_000)
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable<Float64>(key: key, defaultValue: defaultValue)
        setProviderValue(.double(initialValue), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.double(updatedValue), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }


    // MARK: - String tests

    @Test
    mutating func valueForStringReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomAlphanumericString()
        let defaultValue = randomAlphanumericString()
        let variable = ConfigVariable<String>(key: key, defaultValue: defaultValue)
        setProviderValue(.string(expectedValue), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func valueForStringReturnsDefaultWhenKeyNotFound() {
        // set up
        let key = randomConfigKey()
        let defaultValue = randomAlphanumericString()
        let variable = ConfigVariable<String>(key: key, defaultValue: defaultValue)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == defaultValue)
    }


    @Test
    mutating func fetchValueForStringReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomAlphanumericString()
        let defaultValue = randomAlphanumericString()
        let variable = ConfigVariable<String>(key: key, defaultValue: defaultValue)
        setProviderValue(.string(expectedValue), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForStringReturnsDefaultWhenKeyNotFound() async throws {
        // set up
        let key = randomConfigKey()
        let defaultValue = randomAlphanumericString()
        let variable = ConfigVariable<String>(key: key, defaultValue: defaultValue)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == defaultValue)
    }


    @Test
    mutating func watchValueForStringReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = randomAlphanumericString()
        let updatedValue = randomAlphanumericString()
        let defaultValue = randomAlphanumericString()
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable<String>(key: key, defaultValue: defaultValue)
        setProviderValue(.string(initialValue), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.string(updatedValue), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }


    @Test
    mutating func subscriptStringReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomAlphanumericString()
        let defaultValue = randomAlphanumericString()
        let variable = ConfigVariable<String>(key: key, defaultValue: defaultValue)
        setProviderValue(.string(expectedValue), forKey: key)

        // exercise
        let result = reader[variable]

        // expect
        #expect(result == expectedValue)
    }


    // MARK: - [UInt8] tests

    @Test
    mutating func valueForBytesReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomBytes()
        let defaultValue = randomBytes()
        let variable = ConfigVariable<[UInt8]>(key: key, defaultValue: defaultValue)
        setProviderValue(.bytes(expectedValue), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForBytesReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomBytes()
        let defaultValue = randomBytes()
        let variable = ConfigVariable<[UInt8]>(key: key, defaultValue: defaultValue)
        setProviderValue(.bytes(expectedValue), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func watchValueForBytesReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = randomBytes()
        let updatedValue = randomBytes()
        let defaultValue = randomBytes()
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable<[UInt8]>(key: key, defaultValue: defaultValue)
        setProviderValue(.bytes(initialValue), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.bytes(updatedValue), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }
}
