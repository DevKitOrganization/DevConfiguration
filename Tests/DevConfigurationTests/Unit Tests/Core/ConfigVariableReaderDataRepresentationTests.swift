//
//  ConfigVariableReaderDataRepresentationTests.swift
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

struct ConfigVariableReaderDataRepresentationTests: RandomValueGenerating {
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


    // MARK: - JSON Data Representation Tests

    @Test
    mutating func valueForJSONWithDataRepresentationReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = MockCodableConfig(
            variant: randomAlphanumericString(),
            count: randomInt(in: 1 ... 100)
        )
        let defaultValue = MockCodableConfig(
            variant: randomAlphanumericString(),
            count: randomInt(in: 1 ... 100)
        )
        let variable = ConfigVariable(
            key: key,
            defaultValue: defaultValue,
            content: .json(representation: .data)
        )
        let jsonData = try! JSONEncoder().encode(expectedValue)
        setProviderValue(.bytes(Array(jsonData)), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForJSONWithDataRepresentationReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = MockCodableConfig(
            variant: randomAlphanumericString(),
            count: randomInt(in: 1 ... 100)
        )
        let defaultValue = MockCodableConfig(
            variant: randomAlphanumericString(),
            count: randomInt(in: 1 ... 100)
        )
        let variable = ConfigVariable(
            key: key,
            defaultValue: defaultValue,
            content: .json(representation: .data)
        )
        let jsonData = try! JSONEncoder().encode(expectedValue)
        setProviderValue(.bytes(Array(jsonData)), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func watchValueForJSONWithDataRepresentationReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = MockCodableConfig(
            variant: randomAlphanumericString(),
            count: randomInt(in: 1 ... 100)
        )
        let updatedValue = MockCodableConfig(
            variant: randomAlphanumericString(),
            count: randomInt(in: 1 ... 100)
        )
        let defaultValue = MockCodableConfig(
            variant: randomAlphanumericString(),
            count: randomInt(in: 1 ... 100)
        )
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable(
            key: key,
            defaultValue: defaultValue,
            content: .json(representation: .data)
        )
        let encoder = JSONEncoder()
        let initialJSON = try! encoder.encode(initialValue)
        let updatedJSON = try! encoder.encode(updatedValue)
        setProviderValue(.bytes(Array(initialJSON)), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.bytes(Array(updatedJSON)), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }
}
