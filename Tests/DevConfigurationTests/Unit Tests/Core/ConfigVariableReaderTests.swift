//
//  ConfigVariableReaderTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 2/16/2026.
//

import Configuration
import DevFoundation
import DevTesting
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
    mutating func fetchValueForBoolReturnsProviderValue() async throws {
        try await testFetchValueReturnsProviderValue(using: BoolTestHelper())
    }


    @Test
    mutating func fetchValueForBoolReturnsDefaultWhenKeyNotFound() async throws {
        try await testFetchValueReturnsDefaultWhenKeyNotFound(using: BoolTestHelper())
    }


    @Test
    mutating func watchValueForBoolReceivesUpdates() async throws {
        try await testWatchValueReceivesUpdates(using: BoolTestHelper())
    }


    @Test
    mutating func subscriptBoolReturnsProviderValue() {
        testSubscriptReturnsProviderValue(using: BoolTestHelper())
    }


    // MARK: - [Bool] tests

    @Test
    mutating func valueForBoolArrayReturnsProviderValue() {
        testValueReturnsProviderValue(using: BoolArrayTestHelper())
    }


    @Test
    mutating func valueForBoolArrayReturnsDefaultWhenKeyNotFound() {
        testValueReturnsDefaultWhenKeyNotFound(using: BoolArrayTestHelper())
    }


    @Test
    mutating func fetchValueForBoolArrayReturnsProviderValue() async throws {
        try await testFetchValueReturnsProviderValue(using: BoolArrayTestHelper())
    }


    @Test
    mutating func fetchValueForBoolArrayReturnsDefaultWhenKeyNotFound() async throws {
        try await testFetchValueReturnsDefaultWhenKeyNotFound(using: BoolArrayTestHelper())
    }


    @Test
    mutating func watchValueForBoolArrayReceivesUpdates() async throws {
        try await testWatchValueReceivesUpdates(using: BoolArrayTestHelper())
    }


    @Test
    mutating func subscriptBoolArrayReturnsProviderValue() {
        testSubscriptReturnsProviderValue(using: BoolArrayTestHelper())
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
    mutating func fetchValueForFloat64ReturnsProviderValue() async throws {
        try await testFetchValueReturnsProviderValue(using: Float64TestHelper())
    }


    @Test
    mutating func fetchValueForFloat64ReturnsDefaultWhenKeyNotFound() async throws {
        try await testFetchValueReturnsDefaultWhenKeyNotFound(using: Float64TestHelper())
    }


    @Test
    mutating func watchValueForFloat64ReceivesUpdates() async throws {
        try await testWatchValueReceivesUpdates(using: Float64TestHelper())
    }


    @Test
    mutating func subscriptFloat64ReturnsProviderValue() {
        testSubscriptReturnsProviderValue(using: Float64TestHelper())
    }


    // MARK: - [Float64] tests

    @Test
    mutating func valueForFloat64ArrayReturnsProviderValue() {
        testValueReturnsProviderValue(using: Float64ArrayTestHelper())
    }


    @Test
    mutating func valueForFloat64ArrayReturnsDefaultWhenKeyNotFound() {
        testValueReturnsDefaultWhenKeyNotFound(using: Float64ArrayTestHelper())
    }


    @Test
    mutating func fetchValueForFloat64ArrayReturnsProviderValue() async throws {
        try await testFetchValueReturnsProviderValue(using: Float64ArrayTestHelper())
    }


    @Test
    mutating func fetchValueForFloat64ArrayReturnsDefaultWhenKeyNotFound() async throws {
        try await testFetchValueReturnsDefaultWhenKeyNotFound(using: Float64ArrayTestHelper())
    }


    @Test
    mutating func watchValueForFloat64ArrayReceivesUpdates() async throws {
        try await testWatchValueReceivesUpdates(using: Float64ArrayTestHelper())
    }


    @Test
    mutating func subscriptFloat64ArrayReturnsProviderValue() {
        testSubscriptReturnsProviderValue(using: Float64ArrayTestHelper())
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
    mutating func fetchValueForIntReturnsProviderValue() async throws {
        try await testFetchValueReturnsProviderValue(using: IntTestHelper())
    }


    @Test
    mutating func fetchValueForIntReturnsDefaultWhenKeyNotFound() async throws {
        try await testFetchValueReturnsDefaultWhenKeyNotFound(using: IntTestHelper())
    }


    @Test
    mutating func watchValueForIntReceivesUpdates() async throws {
        try await testWatchValueReceivesUpdates(using: IntTestHelper())
    }


    @Test
    mutating func subscriptIntReturnsProviderValue() {
        testSubscriptReturnsProviderValue(using: IntTestHelper())
    }


    // MARK: - [Int] tests

    @Test
    mutating func valueForIntArrayReturnsProviderValue() {
        testValueReturnsProviderValue(using: IntArrayTestHelper())
    }


    @Test
    mutating func valueForIntArrayReturnsDefaultWhenKeyNotFound() {
        testValueReturnsDefaultWhenKeyNotFound(using: IntArrayTestHelper())
    }


    @Test
    mutating func fetchValueForIntArrayReturnsProviderValue() async throws {
        try await testFetchValueReturnsProviderValue(using: IntArrayTestHelper())
    }


    @Test
    mutating func fetchValueForIntArrayReturnsDefaultWhenKeyNotFound() async throws {
        try await testFetchValueReturnsDefaultWhenKeyNotFound(using: IntArrayTestHelper())
    }


    @Test
    mutating func watchValueForIntArrayReceivesUpdates() async throws {
        try await testWatchValueReceivesUpdates(using: IntArrayTestHelper())
    }


    @Test
    mutating func subscriptIntArrayReturnsProviderValue() {
        testSubscriptReturnsProviderValue(using: IntArrayTestHelper())
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
    mutating func fetchValueForStringReturnsProviderValue() async throws {
        try await testFetchValueReturnsProviderValue(using: StringTestHelper())
    }


    @Test
    mutating func fetchValueForStringReturnsDefaultWhenKeyNotFound() async throws {
        try await testFetchValueReturnsDefaultWhenKeyNotFound(using: StringTestHelper())
    }


    @Test
    mutating func watchValueForStringReceivesUpdates() async throws {
        try await testWatchValueReceivesUpdates(using: StringTestHelper())
    }


    @Test
    mutating func subscriptStringReturnsProviderValue() {
        testSubscriptReturnsProviderValue(using: StringTestHelper())
    }


    // MARK: - [String] tests

    @Test
    mutating func valueForStringArrayReturnsProviderValue() {
        testValueReturnsProviderValue(using: StringArrayTestHelper())
    }


    @Test
    mutating func valueForStringArrayReturnsDefaultWhenKeyNotFound() {
        testValueReturnsDefaultWhenKeyNotFound(using: StringArrayTestHelper())
    }


    @Test
    mutating func fetchValueForStringArrayReturnsProviderValue() async throws {
        try await testFetchValueReturnsProviderValue(using: StringArrayTestHelper())
    }


    @Test
    mutating func fetchValueForStringArrayReturnsDefaultWhenKeyNotFound() async throws {
        try await testFetchValueReturnsDefaultWhenKeyNotFound(using: StringArrayTestHelper())
    }


    @Test
    mutating func watchValueForStringArrayReceivesUpdates() async throws {
        try await testWatchValueReceivesUpdates(using: StringArrayTestHelper())
    }


    @Test
    mutating func subscriptStringArrayReturnsProviderValue() {
        testSubscriptReturnsProviderValue(using: StringArrayTestHelper())
    }


    // MARK: - [UInt8] tests

    @Test
    mutating func valueForBytesReturnsProviderValue() {
        testValueReturnsProviderValue(using: BytesTestHelper())
    }


    @Test
    mutating func valueForBytesReturnsDefaultWhenKeyNotFound() {
        testValueReturnsDefaultWhenKeyNotFound(using: BytesTestHelper())
    }


    @Test
    mutating func fetchValueForBytesReturnsProviderValue() async throws {
        try await testFetchValueReturnsProviderValue(using: BytesTestHelper())
    }


    @Test
    mutating func fetchValueForBytesReturnsDefaultWhenKeyNotFound() async throws {
        try await testFetchValueReturnsDefaultWhenKeyNotFound(using: BytesTestHelper())
    }


    @Test
    mutating func watchValueForBytesReceivesUpdates() async throws {
        try await testWatchValueReceivesUpdates(using: BytesTestHelper())
    }


    @Test
    mutating func subscriptBytesReturnsProviderValue() {
        testSubscriptReturnsProviderValue(using: BytesTestHelper())
    }


    // MARK: - [[UInt8]] tests

    @Test
    mutating func valueForByteChunkArrayReturnsProviderValue() {
        testValueReturnsProviderValue(using: ByteChunkArrayTestHelper())
    }


    @Test
    mutating func valueForByteChunkArrayReturnsDefaultWhenKeyNotFound() {
        testValueReturnsDefaultWhenKeyNotFound(using: ByteChunkArrayTestHelper())
    }


    @Test
    mutating func fetchValueForByteChunkArrayReturnsProviderValue() async throws {
        try await testFetchValueReturnsProviderValue(using: ByteChunkArrayTestHelper())
    }


    @Test
    mutating func fetchValueForByteChunkArrayReturnsDefaultWhenKeyNotFound() async throws {
        try await testFetchValueReturnsDefaultWhenKeyNotFound(using: ByteChunkArrayTestHelper())
    }


    @Test
    mutating func watchValueForByteChunkArrayReceivesUpdates() async throws {
        try await testWatchValueReceivesUpdates(using: ByteChunkArrayTestHelper())
    }


    @Test
    mutating func subscriptByteChunkArrayReturnsProviderValue() {
        testSubscriptReturnsProviderValue(using: ByteChunkArrayTestHelper())
    }


    // MARK: - Generic Test Helpers

    /// Tests that `value(for:)` returns the provider value when the key exists.
    mutating func testValueReturnsProviderValue<Helper: ReaderTestHelper>(using helper: Helper) {
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
        let result = helper.getValue(from: reader, for: variable)

        // expect
        #expect(result == expectedValue)
    }


    /// Tests that `value(for:)` returns the default value when the key is not found.
    mutating func testValueReturnsDefaultWhenKeyNotFound<Helper: ReaderTestHelper>(using helper: Helper) {
        // set up
        let key = randomConfigKey()
        let defaultValue = helper.randomValue(using: &randomNumberGenerator)
        let variable = ConfigVariable<Helper.Value>(key: key, defaultValue: defaultValue)

        // exercise
        let result = helper.getValue(from: reader, for: variable)

        // expect
        #expect(result == defaultValue)
    }


    /// Tests that `fetchValue(for:)` returns the provider value when the key exists.
    mutating func testFetchValueReturnsProviderValue<Helper: ReaderTestHelper>(
        using helper: Helper
    ) async throws {
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
        let result = try await helper.fetchValue(from: reader, for: variable)

        // expect
        #expect(result == expectedValue)
    }


    /// Tests that `fetchValue(for:)` returns the default value when the key is not found.
    mutating func testFetchValueReturnsDefaultWhenKeyNotFound<Helper: ReaderTestHelper>(
        using helper: Helper
    ) async throws {
        // set up
        let key = randomConfigKey()
        let defaultValue = helper.randomValue(using: &randomNumberGenerator)
        let variable = ConfigVariable<Helper.Value>(key: key, defaultValue: defaultValue)

        // exercise
        let result = try await helper.fetchValue(from: reader, for: variable)

        // expect
        #expect(result == defaultValue)
    }


    /// Tests that `watchValue(for:updatesHandler:)` receives updates when the provider value changes.
    mutating func testWatchValueReceivesUpdates<Helper: ReaderTestHelper>(
        using helper: Helper
    ) async throws {
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
        try await helper.watchValue(from: reader, for: variable) { (updates) in
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
    mutating func testSubscriptReturnsProviderValue<Helper: ReaderTestHelper>(using helper: Helper) {
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
        let result = helper.subscriptValue(from: reader, for: variable)

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
}


// MARK: - ReaderTestHelper Protocol

/// A protocol that abstracts the type-specific details needed to test `ConfigVariableReader` with different value
/// types.
///
/// Each conforming type encapsulates random value generation, config content conversion, and reader interaction for a
/// specific value type.
protocol ReaderTestHelper<Value> {
    /// The configuration value type being tested.
    associatedtype Value: Equatable & Sendable

    /// Generates a random value of the associated type.
    func randomValue(using generator: inout some RandomNumberGenerator) -> Value

    /// Returns a value that is different from the provided value.
    func differentValue(from value: Value, using generator: inout some RandomNumberGenerator) -> Value

    /// Converts the value to its corresponding `ConfigContent` representation.
    func configContent(for value: Value) -> ConfigContent

    /// Gets the value from the reader using `value(for:)`.
    func getValue(from reader: ConfigVariableReader, for variable: ConfigVariable<Value>) -> Value

    /// Fetches the value from the reader using `fetchValue(for:)`.
    func fetchValue(from reader: ConfigVariableReader, for variable: ConfigVariable<Value>) async throws -> Value

    /// Watches the value from the reader using `watchValue(for:updatesHandler:)`.
    func watchValue<Return>(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<Value>,
        updatesHandler: (ConfigUpdatesAsyncSequence<Value, Never>) async throws -> Return
    ) async throws -> Return

    /// Gets the value from the reader using the subscript.
    func subscriptValue(from reader: ConfigVariableReader, for variable: ConfigVariable<Value>) -> Value
}


// MARK: - BoolTestHelper

private struct BoolTestHelper: ReaderTestHelper {
    func randomValue(using generator: inout some RandomNumberGenerator) -> Bool {
        Bool.random(using: &generator)
    }


    func differentValue(from value: Bool, using generator: inout some RandomNumberGenerator) -> Bool {
        !value
    }


    func configContent(for value: Bool) -> ConfigContent {
        .bool(value)
    }


    func getValue(from reader: ConfigVariableReader, for variable: ConfigVariable<Bool>) -> Bool {
        reader.value(for: variable)
    }


    func fetchValue(from reader: ConfigVariableReader, for variable: ConfigVariable<Bool>) async throws -> Bool {
        try await reader.fetchValue(for: variable)
    }


    func watchValue<Return>(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<Bool>,
        updatesHandler: (ConfigUpdatesAsyncSequence<Bool, Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchValue(for: variable, updatesHandler: updatesHandler)
    }


    func subscriptValue(from reader: ConfigVariableReader, for variable: ConfigVariable<Bool>) -> Bool {
        reader[variable]
    }
}


// MARK: - Float64TestHelper

private struct Float64TestHelper: ReaderTestHelper {
    func randomValue(using generator: inout some RandomNumberGenerator) -> Float64 {
        Float64.random(in: 1 ... 100_000, using: &generator)
    }


    func differentValue(from value: Float64, using generator: inout some RandomNumberGenerator) -> Float64 {
        value + randomValue(using: &generator)
    }


    func configContent(for value: Float64) -> ConfigContent {
        .double(value)
    }


    func getValue(from reader: ConfigVariableReader, for variable: ConfigVariable<Float64>) -> Float64 {
        reader.value(for: variable)
    }


    func fetchValue(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<Float64>
    ) async throws -> Float64 {
        try await reader.fetchValue(for: variable)
    }


    func watchValue<Return>(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<Float64>,
        updatesHandler: (ConfigUpdatesAsyncSequence<Float64, Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchValue(for: variable, updatesHandler: updatesHandler)
    }


    func subscriptValue(from reader: ConfigVariableReader, for variable: ConfigVariable<Float64>) -> Float64 {
        reader[variable]
    }
}


// MARK: - IntTestHelper

private struct IntTestHelper: ReaderTestHelper {
    func randomValue(using generator: inout some RandomNumberGenerator) -> Int {
        Int.random(in: 1 ... 100_000, using: &generator)
    }


    func differentValue(from value: Int, using generator: inout some RandomNumberGenerator) -> Int {
        value + randomValue(using: &generator)
    }


    func configContent(for value: Int) -> ConfigContent {
        .int(value)
    }


    func getValue(from reader: ConfigVariableReader, for variable: ConfigVariable<Int>) -> Int {
        reader.value(for: variable)
    }


    func fetchValue(from reader: ConfigVariableReader, for variable: ConfigVariable<Int>) async throws -> Int {
        try await reader.fetchValue(for: variable)
    }


    func watchValue<Return>(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<Int>,
        updatesHandler: (ConfigUpdatesAsyncSequence<Int, Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchValue(for: variable, updatesHandler: updatesHandler)
    }


    func subscriptValue(from reader: ConfigVariableReader, for variable: ConfigVariable<Int>) -> Int {
        reader[variable]
    }
}


// MARK: - StringTestHelper

private struct StringTestHelper: ReaderTestHelper {
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


    func getValue(from reader: ConfigVariableReader, for variable: ConfigVariable<String>) -> String {
        reader.value(for: variable)
    }


    func fetchValue(from reader: ConfigVariableReader, for variable: ConfigVariable<String>) async throws -> String {
        try await reader.fetchValue(for: variable)
    }


    func watchValue<Return>(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<String>,
        updatesHandler: (ConfigUpdatesAsyncSequence<String, Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchValue(for: variable, updatesHandler: updatesHandler)
    }


    func subscriptValue(from reader: ConfigVariableReader, for variable: ConfigVariable<String>) -> String {
        reader[variable]
    }
}


// MARK: - BytesTestHelper

private struct BytesTestHelper: ReaderTestHelper {
    func randomValue(using generator: inout some RandomNumberGenerator) -> [UInt8] {
        let count = Int.random(in: 1 ... 32, using: &generator)
        return Array(count: count) { UInt8.random(in: .min ... .max, using: &generator) }
    }


    func differentValue(from value: [UInt8], using generator: inout some RandomNumberGenerator) -> [UInt8] {
        value + randomValue(using: &generator)
    }


    func configContent(for value: [UInt8]) -> ConfigContent {
        .bytes(value)
    }


    func getValue(from reader: ConfigVariableReader, for variable: ConfigVariable<[UInt8]>) -> [UInt8] {
        reader.value(for: variable)
    }


    func fetchValue(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<[UInt8]>
    ) async throws -> [UInt8] {
        try await reader.fetchValue(for: variable)
    }


    func watchValue<Return>(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<[UInt8]>,
        updatesHandler: (ConfigUpdatesAsyncSequence<[UInt8], Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchValue(for: variable, updatesHandler: updatesHandler)
    }


    func subscriptValue(from reader: ConfigVariableReader, for variable: ConfigVariable<[UInt8]>) -> [UInt8] {
        reader[variable]
    }
}


// MARK: - BoolArrayTestHelper

private struct BoolArrayTestHelper: ReaderTestHelper {
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


    func getValue(from reader: ConfigVariableReader, for variable: ConfigVariable<[Bool]>) -> [Bool] {
        reader.value(for: variable)
    }


    func fetchValue(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<[Bool]>
    ) async throws -> [Bool] {
        try await reader.fetchValue(for: variable)
    }


    func watchValue<Return>(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<[Bool]>,
        updatesHandler: (ConfigUpdatesAsyncSequence<[Bool], Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchValue(for: variable, updatesHandler: updatesHandler)
    }


    func subscriptValue(from reader: ConfigVariableReader, for variable: ConfigVariable<[Bool]>) -> [Bool] {
        reader[variable]
    }
}


// MARK: - Float64ArrayTestHelper

private struct Float64ArrayTestHelper: ReaderTestHelper {
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


    func getValue(from reader: ConfigVariableReader, for variable: ConfigVariable<[Float64]>) -> [Float64] {
        reader.value(for: variable)
    }


    func fetchValue(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<[Float64]>
    ) async throws -> [Float64] {
        try await reader.fetchValue(for: variable)
    }


    func watchValue<Return>(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<[Float64]>,
        updatesHandler: (ConfigUpdatesAsyncSequence<[Float64], Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchValue(for: variable, updatesHandler: updatesHandler)
    }


    func subscriptValue(from reader: ConfigVariableReader, for variable: ConfigVariable<[Float64]>) -> [Float64] {
        reader[variable]
    }
}


// MARK: - IntArrayTestHelper

private struct IntArrayTestHelper: ReaderTestHelper {
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


    func getValue(from reader: ConfigVariableReader, for variable: ConfigVariable<[Int]>) -> [Int] {
        reader.value(for: variable)
    }


    func fetchValue(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<[Int]>
    ) async throws -> [Int] {
        try await reader.fetchValue(for: variable)
    }


    func watchValue<Return>(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<[Int]>,
        updatesHandler: (ConfigUpdatesAsyncSequence<[Int], Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchValue(for: variable, updatesHandler: updatesHandler)
    }


    func subscriptValue(from reader: ConfigVariableReader, for variable: ConfigVariable<[Int]>) -> [Int] {
        reader[variable]
    }
}


// MARK: - StringArrayTestHelper

private struct StringArrayTestHelper: ReaderTestHelper {
    func randomValue(using generator: inout some RandomNumberGenerator) -> [String] {
        let count = Int.random(in: 1 ... 5, using: &generator)
        return Array(count: count) { String.randomAlphanumeric(count: count * 3, using: &generator) }
    }


    func differentValue(from value: [String], using generator: inout some RandomNumberGenerator) -> [String] {
        value + randomValue(using: &generator)
    }


    func configContent(for value: [String]) -> ConfigContent {
        .stringArray(value)
    }


    func getValue(from reader: ConfigVariableReader, for variable: ConfigVariable<[String]>) -> [String] {
        reader.value(for: variable)
    }


    func fetchValue(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<[String]>
    ) async throws -> [String] {
        try await reader.fetchValue(for: variable)
    }


    func watchValue<Return>(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<[String]>,
        updatesHandler: (ConfigUpdatesAsyncSequence<[String], Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchValue(for: variable, updatesHandler: updatesHandler)
    }


    func subscriptValue(from reader: ConfigVariableReader, for variable: ConfigVariable<[String]>) -> [String] {
        reader[variable]
    }
}


// MARK: - ByteChunkArrayTestHelper

private struct ByteChunkArrayTestHelper: ReaderTestHelper {
    func randomValue(using generator: inout some RandomNumberGenerator) -> [[UInt8]] {
        let count = Int.random(in: 1 ... 5, using: &generator)
        return Array(count: count) {
            let byteCount = Int.random(in: 1 ... 32, using: &generator)
            return Array(count: byteCount) { UInt8.random(in: .min ... .max, using: &generator) }
        }
    }


    func differentValue(from value: [[UInt8]], using generator: inout some RandomNumberGenerator) -> [[UInt8]] {
        value + randomValue(using: &generator)
    }


    func configContent(for value: [[UInt8]]) -> ConfigContent {
        .byteChunkArray(value)
    }


    func getValue(from reader: ConfigVariableReader, for variable: ConfigVariable<[[UInt8]]>) -> [[UInt8]] {
        reader.value(for: variable)
    }


    func fetchValue(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<[[UInt8]]>
    ) async throws -> [[UInt8]] {
        try await reader.fetchValue(for: variable)
    }


    func watchValue<Return>(
        from reader: ConfigVariableReader,
        for variable: ConfigVariable<[[UInt8]]>,
        updatesHandler: (ConfigUpdatesAsyncSequence<[[UInt8]], Never>) async throws -> Return
    ) async throws -> Return {
        try await reader.watchValue(for: variable, updatesHandler: updatesHandler)
    }


    func subscriptValue(from reader: ConfigVariableReader, for variable: ConfigVariable<[[UInt8]]>) -> [[UInt8]] {
        reader[variable]
    }
}
