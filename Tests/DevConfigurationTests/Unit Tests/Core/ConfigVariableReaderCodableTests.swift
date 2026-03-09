//
//  ConfigVariableReaderCodableTests.swift
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

struct ConfigVariableReaderCodableTests: RandomValueGenerating {
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


    // MARK: - JSON Codable tests

    @Test
    mutating func valueForJSONReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = MockCodableConfig(variant: randomAlphanumericString(), count: randomInt(in: 1 ... 100))
        let defaultValue = MockCodableConfig(variant: randomAlphanumericString(), count: randomInt(in: 1 ... 100))
        let variable = ConfigVariable(key: key, defaultValue: defaultValue, content: .json())
        let jsonData = try! JSONEncoder().encode(expectedValue)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        setProviderValue(.string(jsonString), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func valueForJSONReturnsDefaultWhenKeyNotFound() {
        // set up
        let key = randomConfigKey()
        let defaultValue = MockCodableConfig(variant: randomAlphanumericString(), count: randomInt(in: 1 ... 100))
        let variable = ConfigVariable(key: key, defaultValue: defaultValue, content: .json())

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == defaultValue)
    }


    @Test
    mutating func valueForJSONReturnsDefaultWhenDecodingFails() {
        // set up
        let key = randomConfigKey()
        let defaultValue = MockCodableConfig(variant: randomAlphanumericString(), count: randomInt(in: 1 ... 100))
        let variable = ConfigVariable(key: key, defaultValue: defaultValue, content: .json())
        setProviderValue(.string("not valid json"), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == defaultValue)
    }


    @Test
    mutating func valueForJSONPostsDecodingFailedEventWhenDecodingFails() async throws {
        // set up
        let observer = ContextualBusEventObserver(context: ())
        eventBus.addObserver(observer)

        let key = randomConfigKey()
        let defaultValue = MockCodableConfig(variant: randomAlphanumericString(), count: randomInt(in: 1 ... 100))
        let variable = ConfigVariable(key: key, defaultValue: defaultValue, content: .json())
        setProviderValue(.string("not valid json"), forKey: key)

        let (eventStream, continuation) = AsyncStream<ConfigVariableDecodingFailedEvent>.makeStream()
        observer.addHandler(for: ConfigVariableDecodingFailedEvent.self) { (event, _) in
            continuation.yield(event)
        }

        // exercise
        _ = reader.value(for: variable)

        // expect
        let postedEvent = try #require(await eventStream.first { _ in true })
        #expect(postedEvent.key == AbsoluteConfigKey(variable.key))
        #expect(postedEvent.targetType is MockCodableConfig.Type)
    }


    @Test
    mutating func fetchValueForJSONReturnsProviderValue() async throws {
        // set up
        let key = randomConfigKey()
        let expectedValue = MockCodableConfig(variant: randomAlphanumericString(), count: randomInt(in: 1 ... 100))
        let defaultValue = MockCodableConfig(variant: randomAlphanumericString(), count: randomInt(in: 1 ... 100))
        let variable = ConfigVariable(key: key, defaultValue: defaultValue, content: .json())
        let jsonData = try! JSONEncoder().encode(expectedValue)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        setProviderValue(.string(jsonString), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForJSONReturnsDefaultWhenKeyNotFound() async throws {
        // set up
        let key = randomConfigKey()
        let defaultValue = MockCodableConfig(variant: randomAlphanumericString(), count: randomInt(in: 1 ... 100))
        let variable = ConfigVariable(key: key, defaultValue: defaultValue, content: .json())

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == defaultValue)
    }


    @Test
    mutating func watchValueForJSONReceivesUpdates() async throws {
        // set up
        let key = randomConfigKey()
        let initialValue = MockCodableConfig(variant: randomAlphanumericString(), count: randomInt(in: 1 ... 100))
        let updatedValue = MockCodableConfig(variant: randomAlphanumericString(), count: randomInt(in: 1 ... 100))
        let defaultValue = MockCodableConfig(variant: randomAlphanumericString(), count: randomInt(in: 1 ... 100))
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable(key: key, defaultValue: defaultValue, content: .json())
        let encoder = JSONEncoder()
        let initialJSON = String(data: try! encoder.encode(initialValue), encoding: .utf8)!
        let updatedJSON = String(data: try! encoder.encode(updatedValue), encoding: .utf8)!
        setProviderValue(.string(initialJSON), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.string(updatedJSON), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }


    @Test
    mutating func subscriptJSONReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = MockCodableConfig(variant: randomAlphanumericString(), count: randomInt(in: 1 ... 100))
        let defaultValue = MockCodableConfig(variant: randomAlphanumericString(), count: randomInt(in: 1 ... 100))
        let variable = ConfigVariable(key: key, defaultValue: defaultValue, content: .json())
        let jsonData = try! JSONEncoder().encode(expectedValue)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        setProviderValue(.string(jsonString), forKey: key)

        // exercise
        let result = reader[variable]

        // expect
        #expect(result == expectedValue)
    }


    // MARK: - JSON Codable Error Path Tests

    @Test
    mutating func fetchValueForJSONReturnsDefaultWhenDecodingFails() async throws {
        // set up
        let key = randomConfigKey()
        let defaultValue = MockCodableConfig(
            variant: randomAlphanumericString(),
            count: randomInt(in: 1 ... 100)
        )
        let variable = ConfigVariable(key: key, defaultValue: defaultValue, content: .json())
        setProviderValue(.string("not valid json"), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == defaultValue)
    }


    @Test
    mutating func fetchValueForJSONPostsDecodingFailedEventWhenDecodingFails() async throws {
        // set up
        let observer = ContextualBusEventObserver(context: ())
        eventBus.addObserver(observer)

        let key = randomConfigKey()
        let defaultValue = MockCodableConfig(
            variant: randomAlphanumericString(),
            count: randomInt(in: 1 ... 100)
        )
        let variable = ConfigVariable(key: key, defaultValue: defaultValue, content: .json())
        setProviderValue(.string("not valid json"), forKey: key)

        let (eventStream, continuation) = AsyncStream<ConfigVariableDecodingFailedEvent>.makeStream()
        observer.addHandler(for: ConfigVariableDecodingFailedEvent.self) { (event, _) in
            continuation.yield(event)
        }

        // exercise
        _ = try await reader.fetchValue(for: variable)

        // expect
        let postedEvent = try #require(await eventStream.first { _ in true })
        #expect(postedEvent.key == AbsoluteConfigKey(variable.key))
        #expect(postedEvent.targetType is MockCodableConfig.Type)
    }


    @Test
    mutating func watchValueForJSONYieldsDefaultWhenDecodingFails() async throws {
        // set up
        let key = randomConfigKey()
        let defaultValue = MockCodableConfig(
            variant: randomAlphanumericString(),
            count: randomInt(in: 1 ... 100)
        )
        let validValue = MockCodableConfig(
            variant: randomAlphanumericString(),
            count: randomInt(in: 1 ... 100)
        )
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable(key: key, defaultValue: defaultValue, content: .json())
        let validJSON = String(data: try! JSONEncoder().encode(validValue), encoding: .utf8)!
        setProviderValue(.string("not valid json"), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == defaultValue)

            provider.setValue(
                .init(.string(validJSON), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == validValue)
        }
    }


    @Test
    mutating func watchValueForJSONYieldsDefaultWhenKeyNotFound() async throws {
        // set up
        let key = randomConfigKey()
        let defaultValue = MockCodableConfig(
            variant: randomAlphanumericString(),
            count: randomInt(in: 1 ... 100)
        )
        let validValue = MockCodableConfig(
            variant: randomAlphanumericString(),
            count: randomInt(in: 1 ... 100)
        )
        let isSecret = randomBool()
        let provider = provider
        let variable = ConfigVariable(key: key, defaultValue: defaultValue, content: .json())
        let validJSON = String(data: try! JSONEncoder().encode(validValue), encoding: .utf8)!

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == defaultValue)

            provider.setValue(
                .init(.string(validJSON), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == validValue)
        }
    }


    // MARK: - Property List Codable Tests

    @Test
    mutating func valueForPropertyListReturnsProviderValue() {
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
            content: .propertyList(decoder: PropertyListDecoder())
        )
        let plistData = try! PropertyListEncoder().encode(expectedValue)
        setProviderValue(.bytes(Array(plistData)), forKey: key)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func fetchValueForPropertyListReturnsProviderValue() async throws {
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
            content: .propertyList(decoder: PropertyListDecoder())
        )
        let plistData = try! PropertyListEncoder().encode(expectedValue)
        setProviderValue(.bytes(Array(plistData)), forKey: key)

        // exercise
        let result = try await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    @Test
    mutating func watchValueForPropertyListReceivesUpdates() async throws {
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
            content: .propertyList(decoder: PropertyListDecoder())
        )
        let encoder = PropertyListEncoder()
        let initialPlist = try! encoder.encode(initialValue)
        let updatedPlist = try! encoder.encode(updatedValue)
        setProviderValue(.bytes(Array(initialPlist)), forKey: key)

        // exercise and expect
        try await reader.watchValue(for: variable) { updates in
            var iterator = updates.makeAsyncIterator()

            let value1 = await iterator.next()
            #expect(value1 == initialValue)

            provider.setValue(
                .init(.bytes(Array(updatedPlist)), isSecret: isSecret),
                forKey: .init(key)
            )

            let value2 = await iterator.next()
            #expect(value2 == updatedValue)
        }
    }
}
