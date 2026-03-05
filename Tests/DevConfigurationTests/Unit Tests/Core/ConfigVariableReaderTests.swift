//
//  ConfigVariableReaderTests.swift
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

struct ConfigVariableReaderTests: RandomValueGenerating {
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


    // MARK: - isSecret

    @Test(arguments: ConfigVariableSecrecy.allCases)
    mutating func isSecret(secrecy: ConfigVariableSecrecy) {
        let intVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: randomInt(in: .min ... .max),
            secrecy: secrecy
        )

        let stringVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: randomAlphanumericString(),
            secrecy: secrecy
        )

        let stringArrayVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: Array(count: randomInt(in: 0 ... 5)) { randomAlphanumericString() },
            secrecy: secrecy
        )

        let rawRepresentableStringVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: MockStringEnum.allCases.randomElement(using: &randomNumberGenerator)!,
            secrecy: secrecy
        )

        let rawRepresentableStringArrayVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: Array(count: randomInt(in: 0 ... 5)) {
                MockStringEnum.allCases.randomElement(using: &randomNumberGenerator)!
            },
            secrecy: secrecy
        )

        let expressibleByConfigStringVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: MockConfigStringValue(configString: randomAlphanumericString())!,
            secrecy: secrecy
        )

        let expressibleByConfigStringArrayVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: Array(count: randomInt(in: 0 ... 5)) {
                MockConfigStringValue(configString: randomAlphanumericString())!
            },
            secrecy: secrecy
        )

        let rawRepresentableIntVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: MockIntEnum.allCases.randomElement(using: &randomNumberGenerator)!,
            secrecy: secrecy
        )

        let rawRepresentableIntArrayVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: Array(count: randomInt(in: 0 ... 5)) {
                MockIntEnum.allCases.randomElement(using: &randomNumberGenerator)!
            },
            secrecy: secrecy
        )

        let expressibleByConfigIntVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: MockConfigIntValue(configInt: randomInt(in: .min ... .max))!,
            secrecy: secrecy
        )

        let expressibleByConfigIntArrayVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: Array(count: randomInt(in: 0 ... 5)) {
                MockConfigIntValue(configInt: randomInt(in: .min ... .max))!
            },
            secrecy: secrecy
        )

        let isNotPublic = [.secret, .auto].contains(secrecy)
        let isSecret = secrecy == .secret

        let reader = ConfigVariableReader(providers: [InMemoryProvider(values: [:])], eventBus: EventBus())
        #expect(reader.isSecret(intVariable) == isSecret)
        #expect(reader.isSecret(stringVariable) == isNotPublic)
        #expect(reader.isSecret(stringArrayVariable) == isNotPublic)
        #expect(reader.isSecret(rawRepresentableStringVariable) == isNotPublic)
        #expect(reader.isSecret(rawRepresentableStringArrayVariable) == isNotPublic)
        #expect(reader.isSecret(expressibleByConfigStringVariable) == isNotPublic)
        #expect(reader.isSecret(expressibleByConfigStringArrayVariable) == isNotPublic)
        #expect(reader.isSecret(rawRepresentableIntVariable) == isSecret)
        #expect(reader.isSecret(rawRepresentableIntArrayVariable) == isSecret)
        #expect(reader.isSecret(expressibleByConfigIntVariable) == isSecret)
        #expect(reader.isSecret(expressibleByConfigIntArrayVariable) == isSecret)
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


    // MARK: - RawRepresentable<String> tests

    @Test
    mutating func valueForRawRepresentableStringReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomCase(of: MockStringEnum.self)!
        var defaultValue: MockStringEnum
        repeat { defaultValue = randomCase(of: MockStringEnum.self)! } while defaultValue == expectedValue
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
        let defaultValue = randomCase(of: MockStringEnum.self)!
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
        let expectedValue = randomCase(of: MockStringEnum.self)!
        var defaultValue: MockStringEnum
        repeat { defaultValue = randomCase(of: MockStringEnum.self)! } while defaultValue == expectedValue
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
        let defaultValue = randomCase(of: MockStringEnum.self)!
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
        let initialValue = randomCase(of: MockStringEnum.self)!
        var differentValue: MockStringEnum
        repeat { differentValue = randomCase(of: MockStringEnum.self)! } while differentValue == initialValue
        let updatedValue = differentValue
        let defaultValue = randomCase(of: MockStringEnum.self)!
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
        let expectedValue = randomCase(of: MockStringEnum.self)!
        var defaultValue: MockStringEnum
        repeat { defaultValue = randomCase(of: MockStringEnum.self)! } while defaultValue == expectedValue
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


    // MARK: - RawRepresentable<Int> tests

    @Test
    mutating func valueForRawRepresentableIntReturnsProviderValue() {
        // set up
        let key = randomConfigKey()
        let expectedValue = randomCase(of: MockIntEnum.self)!
        var defaultValue: MockIntEnum
        repeat { defaultValue = randomCase(of: MockIntEnum.self)! } while defaultValue == expectedValue
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
        let defaultValue = randomCase(of: MockIntEnum.self)!
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
        let expectedValue = randomCase(of: MockIntEnum.self)!
        var defaultValue: MockIntEnum
        repeat { defaultValue = randomCase(of: MockIntEnum.self)! } while defaultValue == expectedValue
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
        let defaultValue = randomCase(of: MockIntEnum.self)!
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
        let initialValue = randomCase(of: MockIntEnum.self)!
        var differentValue: MockIntEnum
        repeat { differentValue = randomCase(of: MockIntEnum.self)! } while differentValue == initialValue
        let updatedValue = differentValue
        let defaultValue = randomCase(of: MockIntEnum.self)!
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
        let expectedValue = randomCase(of: MockIntEnum.self)!
        var defaultValue: MockIntEnum
        repeat { defaultValue = randomCase(of: MockIntEnum.self)! } while defaultValue == expectedValue
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


    // MARK: - Event Bus Integration

    @Test
    mutating func valuePostsAccessSucceededEventWhenFound() async throws {
        // set up
        let observer = ContextualBusEventObserver(context: ())
        eventBus.addObserver(observer)

        let key = randomConfigKey()
        let expectedValue = randomBool()
        let variable = ConfigVariable<Bool>(key: key, defaultValue: !expectedValue)
        provider.setValue(
            .init(.bool(expectedValue), isSecret: randomBool()),
            forKey: .init(variable.key)
        )

        let (eventStream, continuation) = AsyncStream<ConfigVariableAccessSucceededEvent>.makeStream()
        observer.addHandler(for: ConfigVariableAccessSucceededEvent.self) { (event, _) in
            continuation.yield(event)
        }

        // exercise
        _ = reader.value(for: variable)

        // expect
        let postedEvent = try #require(await eventStream.first { _ in true })
        #expect(postedEvent.key == AbsoluteConfigKey(variable.key))
        #expect(postedEvent.value.content == .bool(expectedValue))
    }
}


// MARK: - MockCodableConfig

private struct MockCodableConfig: Codable, Hashable, Sendable {
    let variant: String
    let count: Int
}


// MARK: - MockStringEnum

private enum MockStringEnum: String, CaseIterable, Sendable {
    case alpha
    case bravo
    case charlie
    case delta
}


// MARK: - MockIntEnum

private enum MockIntEnum: Int, CaseIterable, Sendable {
    case one = 1
    case two = 2
    case three = 3
    case four = 4
}


// MARK: - MockConfigStringValue

private struct MockConfigStringValue: ExpressibleByConfigString, Hashable, Sendable {
    let stringValue: String
    var description: String { stringValue }

    init?(configString: String) {
        self.stringValue = configString
    }
}


// MARK: - MockConfigIntValue

private struct MockConfigIntValue: ExpressibleByConfigInt, Hashable, Sendable {
    let intValue: Int
    var configInt: Int { intValue }
    var description: String { "\(intValue)" }

    init?(configInt: Int) {
        self.intValue = configInt
    }
}
