//
//  ConfigVariableReaderRawRepresentableTests.swift
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

struct ConfigVariableReaderRawRepresentableTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()

    /// A mutable provider for testing.
    let provider = MutableInMemoryProvider(initialValues: [:])

    /// The event bus for testing event posting.
    let eventBus = EventBus()

    /// The reader under test.
    lazy var reader: ConfigVariableReader = {
        ConfigVariableReader(namedProviders: [.init(provider)], eventBus: eventBus)
    }()

    /// Sets a value in the provider for the given key with a random `isSecret` flag.
    private mutating func setProviderValue(_ content: ConfigContent, forKey key: ConfigKey) {
        provider.setValue(
            .init(content, isSecret: randomBool()),
            forKey: .init(key)
        )
    }


    // MARK: - RawRepresentable<String> tests

    @Test
    mutating func valueForRawRepresentableStringReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomNonIterableStringEnum()
        var defaultValue: MockNonIterableStringEnum
        repeat { defaultValue = randomNonIterableStringEnum() } while defaultValue == expectedValue
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.string(expectedValue.rawValue), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func valueForRawRepresentableStringReturnsDefaultWhenKeyNotFound() {
        // set up
        let key = randomConfigKey()
        let defaultValue = randomNonIterableStringEnum()
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == defaultValue)
    }


    @Test
    mutating func fetchValueForRawRepresentableStringReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomNonIterableStringEnum()
        var defaultValue: MockNonIterableStringEnum
        repeat { defaultValue = randomNonIterableStringEnum() } while defaultValue == expectedValue
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.string(expectedValue.rawValue), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForRawRepresentableStringReturnsDefaultWhenKeyNotFound() async throws {
        // set up
        let key = randomConfigKey()
        let defaultValue = randomNonIterableStringEnum()
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == defaultValue)
    }


    @Test
    mutating func watchValueForRawRepresentableStringReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = randomNonIterableStringEnum()
        var differentValue: MockNonIterableStringEnum
        repeat { differentValue = randomNonIterableStringEnum() } while differentValue == initialValue
        let updatedValue = differentValue
        let defaultValue = randomNonIterableStringEnum()
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.string(initialValue.rawValue), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.string(updatedValue.rawValue), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }


    @Test
    mutating func subscriptRawRepresentableStringReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomNonIterableStringEnum()
        var defaultValue: MockNonIterableStringEnum
        repeat { defaultValue = randomNonIterableStringEnum() } while defaultValue == expectedValue
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.string(expectedValue.rawValue), forKey: key)

        // exercise
        let result = reader[variable]

        // expect
        #expect(result == expectedValue)
    }


    // MARK: - [RawRepresentable<String>] tests

    @Test
    mutating func valueForRawRepresentableStringArrayReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = Array(count: randomInt(in: 1 ... 5)) { randomCase(of: MockStringEnum.self)! }
        let defaultValue = Array(count: randomInt(in: 1 ... 5)) { randomCase(of: MockStringEnum.self)! }
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.stringArray(expectedValue.map(\.rawValue)), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForRawRepresentableStringArrayReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = Array(count: randomInt(in: 1 ... 5)) { randomCase(of: MockStringEnum.self)! }
        let defaultValue = Array(count: randomInt(in: 1 ... 5)) { randomCase(of: MockStringEnum.self)! }
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.stringArray(expectedValue.map(\.rawValue)), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func watchValueForRawRepresentableStringArrayReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = Array(count: randomInt(in: 1 ... 5)) { randomCase(of: MockStringEnum.self)! }
        let updatedValue = Array(count: randomInt(in: 1 ... 5)) { randomCase(of: MockStringEnum.self)! }
        let defaultValue = Array(count: randomInt(in: 1 ... 5)) { randomCase(of: MockStringEnum.self)! }
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.stringArray(initialValue.map(\.rawValue)), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.stringArray(updatedValue.map(\.rawValue)), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }


    // MARK: - RawRepresentable<Int> tests

    @Test
    mutating func valueForRawRepresentableIntReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomNonIterableIntEnum()
        var defaultValue: MockNonIterableIntEnum
        repeat { defaultValue = randomNonIterableIntEnum() } while defaultValue == expectedValue
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.int(expectedValue.rawValue), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func valueForRawRepresentableIntReturnsDefaultWhenKeyNotFound() {
        // set up
        let key = randomConfigKey()
        let defaultValue = randomNonIterableIntEnum()
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == defaultValue)
    }


    @Test
    mutating func fetchValueForRawRepresentableIntReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomNonIterableIntEnum()
        var defaultValue: MockNonIterableIntEnum
        repeat { defaultValue = randomNonIterableIntEnum() } while defaultValue == expectedValue
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.int(expectedValue.rawValue), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForRawRepresentableIntReturnsDefaultWhenKeyNotFound() async throws {
        // set up
        let key = randomConfigKey()
        let defaultValue = randomNonIterableIntEnum()
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == defaultValue)
    }


    @Test
    mutating func watchValueForRawRepresentableIntReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = randomNonIterableIntEnum()
        var differentValue: MockNonIterableIntEnum
        repeat { differentValue = randomNonIterableIntEnum() } while differentValue == initialValue
        let updatedValue = differentValue
        let defaultValue = randomNonIterableIntEnum()
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.int(initialValue.rawValue), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.int(updatedValue.rawValue), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }


    @Test
    mutating func subscriptRawRepresentableIntReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomNonIterableIntEnum()
        var defaultValue: MockNonIterableIntEnum
        repeat { defaultValue = randomNonIterableIntEnum() } while defaultValue == expectedValue
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.int(expectedValue.rawValue), forKey: key)

        // exercise
        let result = reader[variable]

        // expect
        #expect(result == expectedValue)
    }


    // MARK: - [RawRepresentable<Int>] tests

    @Test
    mutating func valueForRawRepresentableIntArrayReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = Array(count: randomInt(in: 1 ... 5)) { randomCase(of: MockIntEnum.self)! }
        let defaultValue = Array(count: randomInt(in: 1 ... 5)) { randomCase(of: MockIntEnum.self)! }
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.intArray(expectedValue.map(\.rawValue)), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForRawRepresentableIntArrayReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = Array(count: randomInt(in: 1 ... 5)) { randomCase(of: MockIntEnum.self)! }
        let defaultValue = Array(count: randomInt(in: 1 ... 5)) { randomCase(of: MockIntEnum.self)! }
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.intArray(expectedValue.map(\.rawValue)), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func watchValueForRawRepresentableIntArrayReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = Array(count: randomInt(in: 1 ... 5)) { randomCase(of: MockIntEnum.self)! }
        let updatedValue = Array(count: randomInt(in: 1 ... 5)) { randomCase(of: MockIntEnum.self)! }
        let defaultValue = Array(count: randomInt(in: 1 ... 5)) { randomCase(of: MockIntEnum.self)! }
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.intArray(initialValue.map(\.rawValue)), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.intArray(updatedValue.map(\.rawValue)), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }
}
