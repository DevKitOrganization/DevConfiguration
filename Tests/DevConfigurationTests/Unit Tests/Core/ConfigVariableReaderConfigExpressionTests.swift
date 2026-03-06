//
//  ConfigVariableReaderConfigExpressionTests.swift
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

struct ConfigVariableReaderConfigExpressionTests: RandomValueGenerating {
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


    // MARK: - ExpressibleByConfigString tests

    @Test
    mutating func valueForExpressibleByConfigStringReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = MockConfigStringValue(configString: randomAlphanumericString())!
        let defaultValue = MockConfigStringValue(configString: randomAlphanumericString())!
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.string(expectedValue.description), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForExpressibleByConfigStringReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = MockConfigStringValue(configString: randomAlphanumericString())!
        let defaultValue = MockConfigStringValue(configString: randomAlphanumericString())!
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.string(expectedValue.description), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func watchValueForExpressibleByConfigStringReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = MockConfigStringValue(configString: randomAlphanumericString())!
        let updatedValue = MockConfigStringValue(configString: randomAlphanumericString())!
        let defaultValue = MockConfigStringValue(configString: randomAlphanumericString())!
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.string(initialValue.description), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.string(updatedValue.description), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }


    // MARK: - [ExpressibleByConfigString] tests

    @Test
    mutating func valueForExpressibleByConfigStringArrayReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = Array(count: randomInt(in: 1 ... 5)) {
            MockConfigStringValue(configString: randomAlphanumericString())!
        }
        let defaultValue = Array(count: randomInt(in: 1 ... 5)) {
            MockConfigStringValue(configString: randomAlphanumericString())!
        }
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.stringArray(expectedValue.map(\.description)), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForExpressibleByConfigStringArrayReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = Array(count: randomInt(in: 1 ... 5)) {
            MockConfigStringValue(configString: randomAlphanumericString())!
        }
        let defaultValue = Array(count: randomInt(in: 1 ... 5)) {
            MockConfigStringValue(configString: randomAlphanumericString())!
        }
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.stringArray(expectedValue.map(\.description)), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func watchValueForExpressibleByConfigStringArrayReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = Array(count: randomInt(in: 1 ... 5)) {
            MockConfigStringValue(configString: randomAlphanumericString())!
        }
        let updatedValue = Array(count: randomInt(in: 1 ... 5)) {
            MockConfigStringValue(configString: randomAlphanumericString())!
        }
        let defaultValue = Array(count: randomInt(in: 1 ... 5)) {
            MockConfigStringValue(configString: randomAlphanumericString())!
        }
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.stringArray(initialValue.map(\.description)), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.stringArray(updatedValue.map(\.description)), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }


    // MARK: - ExpressibleByConfigInt tests

    @Test
    mutating func valueForExpressibleByConfigIntReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = MockConfigIntValue(configInt: randomInt(in: .min ... .max))!
        let defaultValue = MockConfigIntValue(configInt: randomInt(in: .min ... .max))!
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.int(expectedValue.configInt), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForExpressibleByConfigIntReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = MockConfigIntValue(configInt: randomInt(in: .min ... .max))!
        let defaultValue = MockConfigIntValue(configInt: randomInt(in: .min ... .max))!
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.int(expectedValue.configInt), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func watchValueForExpressibleByConfigIntReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = MockConfigIntValue(configInt: randomInt(in: .min ... .max))!
        let updatedValue = MockConfigIntValue(configInt: randomInt(in: .min ... .max))!
        let defaultValue = MockConfigIntValue(configInt: randomInt(in: .min ... .max))!
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.int(initialValue.configInt), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.int(updatedValue.configInt), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }


    // MARK: - [ExpressibleByConfigInt] tests

    @Test
    mutating func valueForExpressibleByConfigIntArrayReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = Array(count: randomInt(in: 1 ... 5)) {
            MockConfigIntValue(configInt: randomInt(in: .min ... .max))!
        }
        let defaultValue = Array(count: randomInt(in: 1 ... 5)) {
            MockConfigIntValue(configInt: randomInt(in: .min ... .max))!
        }
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.intArray(expectedValue.map(\.configInt)), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForExpressibleByConfigIntArrayReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = Array(count: randomInt(in: 1 ... 5)) {
            MockConfigIntValue(configInt: randomInt(in: .min ... .max))!
        }
        let defaultValue = Array(count: randomInt(in: 1 ... 5)) {
            MockConfigIntValue(configInt: randomInt(in: .min ... .max))!
        }
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.intArray(expectedValue.map(\.configInt)), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func watchValueForExpressibleByConfigIntArrayReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = Array(count: randomInt(in: 1 ... 5)) {
            MockConfigIntValue(configInt: randomInt(in: .min ... .max))!
        }
        let updatedValue = Array(count: randomInt(in: 1 ... 5)) {
            MockConfigIntValue(configInt: randomInt(in: .min ... .max))!
        }
        let defaultValue = Array(count: randomInt(in: 1 ... 5)) {
            MockConfigIntValue(configInt: randomInt(in: .min ... .max))!
        }
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable(key: key, defaultValue: defaultValue)
        setProviderValue(.intArray(initialValue.map(\.configInt)), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.intArray(updatedValue.map(\.configInt)), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }
}
