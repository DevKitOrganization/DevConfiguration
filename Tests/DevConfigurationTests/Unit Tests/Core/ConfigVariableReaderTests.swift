//
//  ConfigVariableReaderTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 2/16/2026.
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


    // MARK: - Bool tests

    @Test
    mutating func valueForBoolReturnsProviderValue() {
        testValueReturnsProviderValue(using: BoolTestHelper())
    }


    @Test
    mutating func valueForBoolReturnsDefaultWhenKeyNotFound() {
        testValueReturnsDefaultWhenKeyNotFound(using: BoolTestHelper())
    }


    @Test
    mutating func fetchValueForBoolReturnsProviderValue() async {
        await testFetchValueReturnsProviderValue(using: BoolTestHelper())
    }


    @Test
    mutating func fetchValueForBoolReturnsDefaultWhenKeyNotFound() async {
        await testFetchValueReturnsDefaultWhenKeyNotFound(using: BoolTestHelper())
    }


    @Test
    mutating func watchValueForBoolReceivesUpdates() async throws {
        try await testWatchValueReceivesUpdates(using: BoolTestHelper())
    }


    @Test
    mutating func subscriptBoolReturnsProviderValue() {
        testSubscriptReturnsProviderValue(using: BoolTestHelper())
    }


    // MARK: - Data tests

    @Test
    mutating func valueForDataReturnsProviderValue() {
        testValueReturnsProviderValue(using: DataTestHelper())
    }


    @Test
    mutating func valueForDataReturnsDefaultWhenKeyNotFound() {
        testValueReturnsDefaultWhenKeyNotFound(using: DataTestHelper())
    }


    @Test
    mutating func fetchValueForDataReturnsProviderValue() async {
        await testFetchValueReturnsProviderValue(using: DataTestHelper())
    }


    @Test
    mutating func fetchValueForDataReturnsDefaultWhenKeyNotFound() async {
        await testFetchValueReturnsDefaultWhenKeyNotFound(using: DataTestHelper())
    }


    @Test
    mutating func watchValueForDataReceivesUpdates() async throws {
        try await testWatchValueReceivesUpdates(using: DataTestHelper())
    }


    @Test
    mutating func subscriptDataReturnsProviderValue() {
        testSubscriptReturnsProviderValue(using: DataTestHelper())
    }


    // MARK: - Float64 tests

    @Test
    mutating func valueForFloat64ReturnsProviderValue() {
        testValueReturnsProviderValue(using: Float64TestHelper())
    }


    @Test
    mutating func valueForFloat64ReturnsDefaultWhenKeyNotFound() {
        testValueReturnsDefaultWhenKeyNotFound(using: Float64TestHelper())
    }


    @Test
    mutating func fetchValueForFloat64ReturnsProviderValue() async {
        await testFetchValueReturnsProviderValue(using: Float64TestHelper())
    }


    @Test
    mutating func fetchValueForFloat64ReturnsDefaultWhenKeyNotFound() async {
        await testFetchValueReturnsDefaultWhenKeyNotFound(using: Float64TestHelper())
    }


    @Test
    mutating func watchValueForFloat64ReceivesUpdates() async throws {
        try await testWatchValueReceivesUpdates(using: Float64TestHelper())
    }


    @Test
    mutating func subscriptFloat64ReturnsProviderValue() {
        testSubscriptReturnsProviderValue(using: Float64TestHelper())
    }


    // MARK: - Int tests

    @Test
    mutating func valueForIntReturnsProviderValue() {
        testValueReturnsProviderValue(using: IntTestHelper())
    }


    @Test
    mutating func valueForIntReturnsDefaultWhenKeyNotFound() {
        testValueReturnsDefaultWhenKeyNotFound(using: IntTestHelper())
    }


    @Test
    mutating func fetchValueForIntReturnsProviderValue() async {
        await testFetchValueReturnsProviderValue(using: IntTestHelper())
    }


    @Test
    mutating func fetchValueForIntReturnsDefaultWhenKeyNotFound() async {
        await testFetchValueReturnsDefaultWhenKeyNotFound(using: IntTestHelper())
    }


    @Test
    mutating func watchValueForIntReceivesUpdates() async throws {
        try await testWatchValueReceivesUpdates(using: IntTestHelper())
    }


    @Test
    mutating func subscriptIntReturnsProviderValue() {
        testSubscriptReturnsProviderValue(using: IntTestHelper())
    }


    // MARK: - String tests

    @Test
    mutating func valueForStringReturnsProviderValue() {
        testValueReturnsProviderValue(using: StringTestHelper())
    }


    @Test
    mutating func valueForStringReturnsDefaultWhenKeyNotFound() {
        testValueReturnsDefaultWhenKeyNotFound(using: StringTestHelper())
    }


    @Test
    mutating func fetchValueForStringReturnsProviderValue() async {
        await testFetchValueReturnsProviderValue(using: StringTestHelper())
    }


    @Test
    mutating func fetchValueForStringReturnsDefaultWhenKeyNotFound() async {
        await testFetchValueReturnsDefaultWhenKeyNotFound(using: StringTestHelper())
    }


    @Test
    mutating func watchValueForStringReceivesUpdates() async throws {
        try await testWatchValueReceivesUpdates(using: StringTestHelper())
    }


    @Test
    mutating func subscriptStringReturnsProviderValue() {
        testSubscriptReturnsProviderValue(using: StringTestHelper())
    }


    // MARK: - [Bool] tests

    @Test
    mutating func valueForBoolArrayReturnsProviderValue() {
        testArrayValueReturnsProviderValue(using: BoolArrayTestHelper())
    }


    @Test
    mutating func valueForBoolArrayReturnsDefaultWhenKeyNotFound() {
        testArrayValueReturnsDefaultWhenKeyNotFound(using: BoolArrayTestHelper())
    }


    @Test
    mutating func fetchValueForBoolArrayReturnsProviderValue() async {
        await testArrayFetchValueReturnsProviderValue(using: BoolArrayTestHelper())
    }


    @Test
    mutating func fetchValueForBoolArrayReturnsDefaultWhenKeyNotFound() async {
        await testArrayFetchValueReturnsDefaultWhenKeyNotFound(using: BoolArrayTestHelper())
    }


    @Test
    mutating func watchValueForBoolArrayReceivesUpdates() async throws {
        try await testArrayWatchValueReceivesUpdates(using: BoolArrayTestHelper())
    }


    @Test
    mutating func subscriptBoolArrayReturnsProviderValue() {
        testArraySubscriptReturnsProviderValue(using: BoolArrayTestHelper())
    }


    // MARK: - [Data] tests

    @Test
    mutating func valueForDataArrayReturnsProviderValue() {
        testArrayValueReturnsProviderValue(using: DataArrayTestHelper())
    }


    @Test
    mutating func valueForDataArrayReturnsDefaultWhenKeyNotFound() {
        testArrayValueReturnsDefaultWhenKeyNotFound(using: DataArrayTestHelper())
    }


    @Test
    mutating func fetchValueForDataArrayReturnsProviderValue() async {
        await testArrayFetchValueReturnsProviderValue(using: DataArrayTestHelper())
    }


    @Test
    mutating func fetchValueForDataArrayReturnsDefaultWhenKeyNotFound() async {
        await testArrayFetchValueReturnsDefaultWhenKeyNotFound(using: DataArrayTestHelper())
    }


    @Test
    mutating func watchValueForDataArrayReceivesUpdates() async throws {
        try await testArrayWatchValueReceivesUpdates(using: DataArrayTestHelper())
    }


    @Test
    mutating func subscriptDataArrayReturnsProviderValue() {
        testArraySubscriptReturnsProviderValue(using: DataArrayTestHelper())
    }


    // MARK: - [Float64] tests

    @Test
    mutating func valueForFloat64ArrayReturnsProviderValue() {
        testArrayValueReturnsProviderValue(using: Float64ArrayTestHelper())
    }


    @Test
    mutating func valueForFloat64ArrayReturnsDefaultWhenKeyNotFound() {
        testArrayValueReturnsDefaultWhenKeyNotFound(using: Float64ArrayTestHelper())
    }


    @Test
    mutating func fetchValueForFloat64ArrayReturnsProviderValue() async {
        await testArrayFetchValueReturnsProviderValue(using: Float64ArrayTestHelper())
    }


    @Test
    mutating func fetchValueForFloat64ArrayReturnsDefaultWhenKeyNotFound() async {
        await testArrayFetchValueReturnsDefaultWhenKeyNotFound(using: Float64ArrayTestHelper())
    }


    @Test
    mutating func watchValueForFloat64ArrayReceivesUpdates() async throws {
        try await testArrayWatchValueReceivesUpdates(using: Float64ArrayTestHelper())
    }


    @Test
    mutating func subscriptFloat64ArrayReturnsProviderValue() {
        testArraySubscriptReturnsProviderValue(using: Float64ArrayTestHelper())
    }


    // MARK: - [Int] tests

    @Test
    mutating func valueForIntArrayReturnsProviderValue() {
        testArrayValueReturnsProviderValue(using: IntArrayTestHelper())
    }


    @Test
    mutating func valueForIntArrayReturnsDefaultWhenKeyNotFound() {
        testArrayValueReturnsDefaultWhenKeyNotFound(using: IntArrayTestHelper())
    }


    @Test
    mutating func fetchValueForIntArrayReturnsProviderValue() async {
        await testArrayFetchValueReturnsProviderValue(using: IntArrayTestHelper())
    }

    @Test
    mutating func fetchValueForIntArrayReturnsDefaultWhenKeyNotFound() async {
        await testArrayFetchValueReturnsDefaultWhenKeyNotFound(using: IntArrayTestHelper())
    }


    @Test
    mutating func watchValueForIntArrayReceivesUpdates() async throws {
        try await testArrayWatchValueReceivesUpdates(using: IntArrayTestHelper())
    }


    @Test
    mutating func subscriptIntArrayReturnsProviderValue() {
        testArraySubscriptReturnsProviderValue(using: IntArrayTestHelper())
    }


    // MARK: - [String] tests

    @Test
    mutating func valueForStringArrayReturnsProviderValue() {
        testArrayValueReturnsProviderValue(using: StringArrayTestHelper())
    }


    @Test
    mutating func valueForStringArrayReturnsDefaultWhenKeyNotFound() {
        testArrayValueReturnsDefaultWhenKeyNotFound(using: StringArrayTestHelper())
    }


    @Test
    mutating func fetchValueForStringArrayReturnsProviderValue() async {
        await testArrayFetchValueReturnsProviderValue(using: StringArrayTestHelper())
    }

    @Test
    mutating func fetchValueForStringArrayReturnsDefaultWhenKeyNotFound() async {
        await testArrayFetchValueReturnsDefaultWhenKeyNotFound(using: StringArrayTestHelper())
    }


    @Test
    mutating func watchValueForStringArrayReceivesUpdates() async throws {
        try await testArrayWatchValueReceivesUpdates(using: StringArrayTestHelper())
    }


    @Test
    mutating func subscriptStringArrayReturnsProviderValue() {
        testArraySubscriptReturnsProviderValue(using: StringArrayTestHelper())
    }


    // MARK: - Generic Test Helpers

    /// Tests that `value(for:)` returns the provider value when the key exists.
    mutating func testValueReturnsProviderValue<Helper: ConfigValueTestHelper>(
        using helper: Helper
    ) where Helper: ConfigValueTestHelper {
        // set up
        let key = randomConfigKey()
        let expectedValue = helper.randomValue(using: &randomNumberGenerator)
        let defaultValue = helper.differentValue(from: expectedValue, using: &randomNumberGenerator)
        let variable = ConfigVariable<Helper.Value>(key: key, defaultValue: defaultValue)
        provider.setValue(
            .init(
                helper.configContent(for: expectedValue),
                isSecret: randomBool()
            ),
            forKey: .init(key)
        )

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    /// Tests that `value(for:)` returns the default value when the key is not found.
    mutating func testValueReturnsDefaultWhenKeyNotFound<Helper: ConfigValueTestHelper>(
        using helper: Helper
    ) where Helper: ConfigValueTestHelper {
        // set up
        let key = randomConfigKey()
        let defaultValue = helper.randomValue(using: &randomNumberGenerator)
        let variable = ConfigVariable<Helper.Value>(key: key, defaultValue: defaultValue)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == defaultValue)
    }


    /// Tests that `fetchValue(for:)` returns the provider value when the key exists.
    mutating func testFetchValueReturnsProviderValue<Helper: ConfigValueTestHelper>(
        using helper: Helper
    ) async where Helper: ConfigValueTestHelper {
        // set up
        let key = randomConfigKey()
        let expectedValue = helper.randomValue(using: &randomNumberGenerator)
        let defaultValue = helper.differentValue(from: expectedValue, using: &randomNumberGenerator)
        let variable = ConfigVariable<Helper.Value>(key: key, defaultValue: defaultValue)
        provider.setValue(
            .init(
                helper.configContent(for: expectedValue),
                isSecret: randomBool()
            ),
            forKey: .init(key)
        )

        // exercise
        let result = await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    /// Tests that `fetchValue(for:)` returns the default value when the key is not found.
    mutating func testFetchValueReturnsDefaultWhenKeyNotFound<Helper: ConfigValueTestHelper>(
        using helper: Helper
    ) async where Helper: ConfigValueTestHelper {
        // set up
        let key = randomConfigKey()
        let defaultValue = helper.randomValue(using: &randomNumberGenerator)
        let variable = ConfigVariable<Helper.Value>(key: key, defaultValue: defaultValue)

        // exercise
        let result = await reader.fetchValue(for: variable)

        // expect
        #expect(result == defaultValue)
    }


    /// Tests that `watchValue(for:)` receives updates when the provider value changes.
    mutating func testWatchValueReceivesUpdates<Helper: ConfigValueTestHelper>(
        using helper: Helper
    ) async throws where Helper: ConfigValueTestHelper {
        // set up
        let key = randomConfigKey()
        let initialValue = helper.randomValue(using: &randomNumberGenerator)
        let updatedValue = helper.differentValue(from: initialValue, using: &randomNumberGenerator)
        let defaultValue = helper.differentValue(from: initialValue, using: &randomNumberGenerator)
        let variable = ConfigVariable<Helper.Value>(key: key, defaultValue: defaultValue)
        provider.setValue(
            .init(
                helper.configContent(for: initialValue),
                isSecret: randomBool()
            ),
            forKey: .init(key)
        )

        // exercise and expect
        try await reader.watchValue(for: variable) { (updates) in
            var iterator = updates.makeAsyncIterator()

            // first value should be initial
            let value1 = try await iterator.next()
            #expect(value1 == initialValue)

            // update the provider
            provider.setValue(
                .init(
                    helper.configContent(for: updatedValue),
                    isSecret: randomBool()
                ),
                forKey: .init(key)
            )

            // next value should be updated
            let value2 = try await iterator.next()
            #expect(value2 == updatedValue)
        }
    }


    /// Tests that subscript returns the provider value when the key exists.
    mutating func testSubscriptReturnsProviderValue<Helper: ConfigValueTestHelper>(
        using helper: Helper
    ) where Helper: ConfigValueTestHelper {
        // set up
        let key = randomConfigKey()
        let expectedValue = helper.randomValue(using: &randomNumberGenerator)
        let defaultValue = helper.differentValue(from: expectedValue, using: &randomNumberGenerator)
        let variable = ConfigVariable<Helper.Value>(key: key, defaultValue: defaultValue)
        provider.setValue(
            .init(
                helper.configContent(for: expectedValue),
                isSecret: randomBool()
            ),
            forKey: .init(key)
        )

        // exercise
        let result = reader[variable]

        // expect
        #expect(result == expectedValue)
    }


    // MARK: - Generic Array Test Helpers

    /// Tests that `value(for:)` returns the provider value when the key exists for array types.
    mutating func testArrayValueReturnsProviderValue<Helper>(
        using helper: Helper
    ) where Helper: ConfigArrayValueTestHelper {
        // set up
        let key = randomConfigKey()
        let expectedValue = helper.randomValue(using: &randomNumberGenerator)
        let defaultValue = helper.differentValue(from: expectedValue, using: &randomNumberGenerator)
        let variable = ConfigVariable<[Helper.Element]>(key: key, defaultValue: defaultValue)
        provider.setValue(
            .init(
                helper.configContent(for: expectedValue),
                isSecret: randomBool()
            ),
            forKey: .init(key)
        )

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    /// Tests that `value(for:)` returns the default value when the key is not found for array types.
    mutating func testArrayValueReturnsDefaultWhenKeyNotFound<Helper>(
        using helper: Helper
    ) where Helper: ConfigArrayValueTestHelper {
        // set up
        let key = randomConfigKey()
        let defaultValue = helper.randomValue(using: &randomNumberGenerator)
        let variable = ConfigVariable<[Helper.Element]>(key: key, defaultValue: defaultValue)

        // exercise
        let result = reader.value(for: variable)

        // expect
        #expect(result == defaultValue)
    }


    /// Tests that `fetchValue(for:)` returns the provider value when the key exists for array types.
    mutating func testArrayFetchValueReturnsProviderValue<Helper>(
        using helper: Helper
    ) async where Helper: ConfigArrayValueTestHelper {
        // set up
        let key = randomConfigKey()
        let expectedValue = helper.randomValue(using: &randomNumberGenerator)
        let defaultValue = helper.differentValue(from: expectedValue, using: &randomNumberGenerator)
        let variable = ConfigVariable<[Helper.Element]>(key: key, defaultValue: defaultValue)
        provider.setValue(
            .init(
                helper.configContent(for: expectedValue),
                isSecret: randomBool()
            ),
            forKey: .init(key)
        )

        // exercise
        let result = await reader.fetchValue(for: variable)

        // expect
        #expect(result == expectedValue)
    }


    /// Tests that `fetchValue(for:)` returns the default value when the key is not found for array types.
    mutating func testArrayFetchValueReturnsDefaultWhenKeyNotFound<Helper>(
        using helper: Helper
    ) async where Helper: ConfigArrayValueTestHelper {
        // set up
        let key = randomConfigKey()
        let defaultValue = helper.randomValue(using: &randomNumberGenerator)
        let variable = ConfigVariable<[Helper.Element]>(key: key, defaultValue: defaultValue)

        // exercise
        let result = await reader.fetchValue(for: variable)

        // expect
        #expect(result == defaultValue)
    }


    /// Tests that `watchValue(for:)` receives updates when the provider value changes for array types.
    mutating func testArrayWatchValueReceivesUpdates<Helper>(
        using helper: Helper
    ) async throws where Helper: ConfigArrayValueTestHelper {
        // set up
        let key = randomConfigKey()
        let initialValue = helper.randomValue(using: &randomNumberGenerator)
        let updatedValue = helper.differentValue(from: initialValue, using: &randomNumberGenerator)
        let defaultValue = helper.differentValue(from: initialValue, using: &randomNumberGenerator)
        let variable = ConfigVariable<[Helper.Element]>(key: key, defaultValue: defaultValue)
        provider.setValue(
            .init(
                helper.configContent(for: initialValue),
                isSecret: randomBool()
            ),
            forKey: .init(key)
        )

        // exercise and expect
        try await reader.watchValue(for: variable) { (updates) in
            var iterator = updates.makeAsyncIterator()

            // first value should be initial
            let value1 = try await iterator.next()
            #expect(value1 == initialValue)

            // update the provider
            provider.setValue(
                .init(
                    helper.configContent(for: updatedValue),
                    isSecret: randomBool()
                ),
                forKey: .init(key)
            )

            // next value should be updated
            let value2 = try await iterator.next()
            #expect(value2 == updatedValue)
        }
    }


    /// Tests that subscript returns the provider value when the key exists for array types.
    mutating func testArraySubscriptReturnsProviderValue<Helper>(
        using helper: Helper
    ) where Helper: ConfigArrayValueTestHelper {
        // set up
        let key = randomConfigKey()
        let expectedValue = helper.randomValue(using: &randomNumberGenerator)
        let defaultValue = helper.differentValue(from: expectedValue, using: &randomNumberGenerator)
        let variable = ConfigVariable<[Helper.Element]>(key: key, defaultValue: defaultValue)
        provider.setValue(
            .init(
                helper.configContent(for: expectedValue),
                isSecret: randomBool()
            ),
            forKey: .init(key)
        )

        // exercise
        let result = reader[variable]

        // expect
        #expect(result == expectedValue)
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
            .init(
                .bool(expectedValue),
                isSecret: randomBool()
            ),
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


    @Test
    mutating func valuePostsAccessFailedEventWhenNotFound() async throws {
        // set up
        let observer = ContextualBusEventObserver(context: ())
        eventBus.addObserver(observer)

        let key = randomConfigKey()
        let defaultValue = randomBool()
        let variable = ConfigVariable<Bool>(key: key, defaultValue: defaultValue)

        let (eventStream, continuation) = AsyncStream<ConfigVariableAccessFailedEvent>.makeStream()
        observer.addHandler(for: ConfigVariableAccessFailedEvent.self) { (event, _) in
            continuation.yield(event)
        }

        // exercise
        _ = reader.value(for: variable)

        // expect
        let postedEvent = try #require(await eventStream.first { _ in true })
        #expect(postedEvent.key == AbsoluteConfigKey(variable.key))
    }
}


// MARK: - ConfigValueTestHelper Protocol

/// A protocol that abstracts the type-specific details needed to test `ConfigVariableReader` with different value
/// types.
///
/// Conforming types provide the logic for generating random values, creating config content, and producing different
/// values for testing default value fallback behavior.
protocol ConfigValueTestHelper<Value> {
    /// The configuration value type being tested.
    associatedtype Value: ConfigValueReadable & Equatable

    /// Generates a random value of the associated type.
    func randomValue(using generator: inout some RandomNumberGenerator) -> Value

    /// Returns a value that is different from the provided value.
    func differentValue(from value: Value, using generator: inout some RandomNumberGenerator) -> Value

    /// Converts the value to its corresponding `ConfigContent` representation.
    func configContent(for value: Value) -> ConfigContent
}


// MARK: - ConfigArrayValueTestHelper Protocol

/// A protocol that abstracts the type-specific details needed to test `ConfigVariableReader` with array value types.
///
/// This is separate from `ConfigValueTestHelper` because array types have their element type conform to
/// `ConfigValueReadable`, not the array type itself.
protocol ConfigArrayValueTestHelper<Element> {
    /// The element type of the array being tested.
    associatedtype Element: ConfigValueReadable & Equatable

    /// Generates a random array value.
    func randomValue(using generator: inout some RandomNumberGenerator) -> [Element]

    /// Returns an array that is different from the provided array.
    func differentValue(from value: [Element], using generator: inout some RandomNumberGenerator) -> [Element]

    /// Converts the array to its corresponding `ConfigContent` representation.
    func configContent(for value: [Element]) -> ConfigContent
}


// MARK: - BoolTestHelper

private struct BoolTestHelper: ConfigValueTestHelper {
    func randomValue(using generator: inout some RandomNumberGenerator) -> Bool {
        Bool.random(using: &generator)
    }


    func differentValue(from value: Bool, using generator: inout some RandomNumberGenerator) -> Bool {
        !value
    }


    func configContent(for value: Bool) -> ConfigContent {
        .bool(value)
    }
}


// MARK: - DataTestHelper

private struct DataTestHelper: ConfigValueTestHelper {
    func randomValue(using generator: inout some RandomNumberGenerator) -> Data {
        let count = Int.random(in: 1 ... 32, using: &generator)
        return Data.random(count: count, using: &generator)
    }


    func differentValue(from value: Data, using generator: inout some RandomNumberGenerator) -> Data {
        value + randomValue(using: &generator)
    }


    func configContent(for value: Data) -> ConfigContent {
        .bytes(Array(value))
    }
}


// MARK: - Float64TestHelper

private struct Float64TestHelper: ConfigValueTestHelper {
    func randomValue(using generator: inout some RandomNumberGenerator) -> Float64 {
        Float64.random(in: 1 ... 100_000, using: &generator)
    }


    func differentValue(from value: Float64, using generator: inout some RandomNumberGenerator) -> Float64 {
        value + randomValue(using: &generator)
    }


    func configContent(for value: Float64) -> ConfigContent {
        .double(value)
    }
}


// MARK: - IntTestHelper

private struct IntTestHelper: ConfigValueTestHelper {
    func randomValue(using generator: inout some RandomNumberGenerator) -> Int {
        Int.random(in: 1 ... 100_000, using: &generator)
    }


    func differentValue(from value: Int, using generator: inout some RandomNumberGenerator) -> Int {
        value + randomValue(using: &generator)
    }


    func configContent(for value: Int) -> ConfigContent {
        .int(value)
    }
}


// MARK: - StringTestHelper

private struct StringTestHelper: ConfigValueTestHelper {
    func randomValue(using generator: inout some RandomNumberGenerator) -> String {
        let count = Int.random(in: 5 ... 20, using: &generator)
        return String.randomAlphanumeric(count: count, using: &generator)
    }


    func differentValue(from value: String, using generator: inout some RandomNumberGenerator) -> String {
        value + randomValue(using: &generator)
    }


    func configContent(for value: String) -> ConfigContent {
        .string(value)
    }
}


// MARK: - BoolArrayTestHelper

private struct BoolArrayTestHelper: ConfigArrayValueTestHelper {
    func randomValue(using generator: inout some RandomNumberGenerator) -> [Bool] {
        let count = Int.random(in: 1 ... 5, using: &generator)
        return Array(count: count) { Bool.random(using: &generator) }
    }


    func differentValue(from value: [Bool], using generator: inout some RandomNumberGenerator) -> [Bool] {
        value + randomValue(using: &generator)
    }


    func configContent(for value: [Bool]) -> ConfigContent {
        .boolArray(value)
    }
}


// MARK: - DataArrayTestHelper

private struct DataArrayTestHelper: ConfigArrayValueTestHelper {
    func randomValue(using generator: inout some RandomNumberGenerator) -> [Data] {
        let count = Int.random(in: 1 ... 5, using: &generator)
        return Array(count: count) {
            let byteCount = Int.random(in: 1 ... 32, using: &generator)
            return Data.random(count: byteCount, using: &generator)
        }
    }


    func differentValue(from value: [Data], using generator: inout some RandomNumberGenerator) -> [Data] {
        value + randomValue(using: &generator)
    }


    func configContent(for value: [Data]) -> ConfigContent {
        .byteChunkArray(value.map { Array($0) })
    }
}


// MARK: - Float64ArrayTestHelper

private struct Float64ArrayTestHelper: ConfigArrayValueTestHelper {
    func randomValue(using generator: inout some RandomNumberGenerator) -> [Float64] {
        let count = Int.random(in: 1 ... 5, using: &generator)
        return Array(count: count) { Float64.random(in: 1 ... 100_000, using: &generator) }
    }


    func differentValue(from value: [Float64], using generator: inout some RandomNumberGenerator) -> [Float64] {
        value + randomValue(using: &generator)
    }


    func configContent(for value: [Float64]) -> ConfigContent {
        .doubleArray(value)
    }
}


// MARK: - IntArrayTestHelper

private struct IntArrayTestHelper: ConfigArrayValueTestHelper {
    func randomValue(using generator: inout some RandomNumberGenerator) -> [Int] {
        let count = Int.random(in: 1 ... 5, using: &generator)
        return Array(count: count) { Int.random(in: 1 ... 100_000, using: &generator) }
    }


    func differentValue(from value: [Int], using generator: inout some RandomNumberGenerator) -> [Int] {
        value + randomValue(using: &generator)
    }


    func configContent(for value: [Int]) -> ConfigContent {
        .intArray(value)
    }
}


// MARK: - StringArrayTestHelper

private struct StringArrayTestHelper: ConfigArrayValueTestHelper {
    func randomValue(using generator: inout some RandomNumberGenerator) -> [String] {
        let count = Int.random(in: 1 ... 5, using: &generator)
        return Array(count: count) { String.randomAlphanumeric(count: count * 3, using: &generator) }
    }


    func differentValue(from value: [String], using generator: inout some RandomNumberGenerator) -> [String] {
        return value + randomValue(using: &generator)
    }


    func configContent(for value: [String]) -> ConfigContent {
        .stringArray(value)
    }
}
