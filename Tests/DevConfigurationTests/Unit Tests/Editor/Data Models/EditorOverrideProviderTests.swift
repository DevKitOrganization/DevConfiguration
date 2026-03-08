//
//  EditorOverrideProviderTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/7/2026.
//

import Configuration
import DevTesting
import Foundation
import Testing

@testable import DevConfiguration

struct EditorOverrideProviderTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    func providerNameIsEditor() {
        // set up
        let provider = EditorOverrideProvider()

        // expect
        #expect(provider.providerName != "editorOverrideProvider.name")
    }


    @Test
    mutating func setOverrideThenRetrieve() {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        let content = ConfigContent.string(randomAlphanumericString())

        // exercise
        provider.setOverride(content, forKey: key)

        // expect
        #expect(provider.overrides[key] == content)
    }


    @Test
    mutating func removeOverrideClearsStoredValue() {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        provider.setOverride(.bool(true), forKey: key)

        // exercise
        provider.removeOverride(forKey: key)

        // expect
        #expect(provider.overrides[key] == nil)
    }


    @Test
    mutating func removeOverrideForNonexistentKeyIsNoOp() {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()

        // exercise
        provider.removeOverride(forKey: key)

        // expect
        #expect(provider.overrides.isEmpty)
    }


    @Test
    func removeAllOverridesWhenEmptyIsNoOp() {
        // set up
        let provider = EditorOverrideProvider()

        // exercise
        provider.removeAllOverrides()

        // expect
        #expect(provider.overrides.isEmpty)
    }


    @Test
    mutating func removeAllOverridesClearsEverything() {
        // set up
        let provider = EditorOverrideProvider()
        let key1 = randomConfigKey()
        let key2 = randomConfigKey()
        provider.setOverride(.int(1), forKey: key1)
        provider.setOverride(.int(2), forKey: key2)

        // exercise
        provider.removeAllOverrides()

        // expect
        #expect(provider.overrides.isEmpty)
    }


    @Test
    mutating func hasOverrideReturnsTrueWhenSet() {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        provider.setOverride(.bool(true), forKey: key)

        // expect
        #expect(provider.hasOverride(forKey: key))
    }


    @Test
    mutating func hasOverrideReturnsFalseWhenNotSet() {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()

        // expect
        #expect(!provider.hasOverride(forKey: key))
    }


    @Test
    mutating func overridesReturnsFullDictionary() {
        // set up
        let provider = EditorOverrideProvider()
        let key1 = randomConfigKey()
        let key2 = randomConfigKey()
        let content1 = ConfigContent.string("a")
        let content2 = ConfigContent.int(42)
        provider.setOverride(content1, forKey: key1)
        provider.setOverride(content2, forKey: key2)

        // expect
        #expect(provider.overrides == [key1: content1, key2: content2])
    }


    @Test
    mutating func valueForKeyReturnsValueWhenTypeMatches() throws {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        let content = ConfigContent.int(42)
        provider.setOverride(content, forKey: key)

        // exercise
        let result = try provider.value(forKey: AbsoluteConfigKey(key), type: .int)

        // expect
        #expect(result.value == ConfigValue(content, isSecret: false))
    }


    @Test
    mutating func valueForKeyReturnsNilValueWhenTypeMismatches() throws {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        provider.setOverride(.int(42), forKey: key)

        // exercise
        let result = try provider.value(forKey: AbsoluteConfigKey(key), type: .string)

        // expect
        #expect(result.value == nil)
    }


    @Test
    mutating func valueForKeyReturnsNilValueWhenKeyNotFound() throws {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()

        // exercise
        let result = try provider.value(forKey: AbsoluteConfigKey(key), type: .string)

        // expect
        #expect(result.value == nil)
    }


    @Test
    mutating func fetchValueDelegatesToValue() async throws {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        let content = ConfigContent.bool(true)
        provider.setOverride(content, forKey: key)

        // exercise
        let result = try await provider.fetchValue(forKey: AbsoluteConfigKey(key), type: .bool)

        // expect
        #expect(result.value == ConfigValue(content, isSecret: false))
    }


    @Test
    mutating func snapshotReturnsCurrentState() throws {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        let content = ConfigContent.double(3.14)
        provider.setOverride(content, forKey: key)

        // exercise
        let snapshot = provider.snapshot()

        // expect
        #expect(snapshot.providerName != "editorOverrideProvider.name")
        let result = try snapshot.value(forKey: AbsoluteConfigKey(key), type: .double)
        #expect(result.value == ConfigValue(content, isSecret: false))
    }


    @Test
    mutating func setOverrideDoesNotNotifyWhenValueUnchanged() async throws {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        let absoluteKey = AbsoluteConfigKey(key)
        provider.setOverride(.int(1), forKey: key)

        // exercise
        try await provider.watchValue(forKey: absoluteKey, type: .int) { updates in
            var iterator = updates.makeAsyncIterator()

            // Consume initial value
            _ = try #require(await iterator.next())

            // Set the same value again
            provider.setOverride(.int(1), forKey: key)

            // Set a different value to verify the stream is still working
            provider.setOverride(.int(2), forKey: key)

            // expect the next emitted value is 2, not 1 (the duplicate was skipped)
            let next = try #require(await iterator.next())
            #expect(try next.get().value == ConfigValue(.int(2), isSecret: false))
        }
    }


    @Test
    mutating func removeOverrideNotifiesValueWatchers() async throws {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        let absoluteKey = AbsoluteConfigKey(key)
        provider.setOverride(.string("hello"), forKey: key)

        // exercise
        try await provider.watchValue(forKey: absoluteKey, type: .string) { updates in
            var iterator = updates.makeAsyncIterator()

            // Consume initial value
            let first = try #require(await iterator.next())
            #expect(try first.get().value == ConfigValue(.string("hello"), isSecret: false))

            // Remove the override
            provider.removeOverride(forKey: key)

            // expect nil value
            let second = try #require(await iterator.next())
            #expect(try second.get().value == nil)
        }
    }


    @Test
    mutating func removeOverrideNotifiesSnapshotWatchers() async throws {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()

        provider.setOverride(.bool(true), forKey: key)

        // exercise
        try await provider.watchSnapshot { updates in
            var iterator = updates.makeAsyncIterator()

            // Consume initial snapshot (has the override)
            let first = try #require(await iterator.next())
            let firstResult = try first.value(forKey: AbsoluteConfigKey(key), type: .bool)
            #expect(firstResult.value != nil)

            // Remove the override
            provider.removeOverride(forKey: key)

            // expect updated snapshot without the override
            let second = try #require(await iterator.next())
            let secondResult = try second.value(forKey: AbsoluteConfigKey(key), type: .bool)
            #expect(secondResult.value == nil)
        }
    }


    @Test
    mutating func removeAllOverridesNotifiesValueWatchers() async throws {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        let absoluteKey = AbsoluteConfigKey(key)
        provider.setOverride(.int(42), forKey: key)

        // exercise
        try await provider.watchValue(forKey: absoluteKey, type: .int) { updates in
            var iterator = updates.makeAsyncIterator()

            // Consume initial value
            let first = try #require(await iterator.next())
            #expect(try first.get().value == ConfigValue(.int(42), isSecret: false))

            // Remove all overrides
            provider.removeAllOverrides()

            // expect nil value
            let second = try #require(await iterator.next())
            #expect(try second.get().value == nil)
        }
    }


    @Test
    mutating func removeAllOverridesNotifiesSnapshotWatchers() async throws {
        // set up
        let provider = EditorOverrideProvider()
        let key1 = randomConfigKey()
        let key2 = randomConfigKey()
        provider.setOverride(.int(1), forKey: key1)
        provider.setOverride(.int(2), forKey: key2)

        // exercise
        try await provider.watchSnapshot { updates in
            var iterator = updates.makeAsyncIterator()

            // Consume initial snapshot
            _ = try #require(await iterator.next())

            // Remove all overrides
            provider.removeAllOverrides()

            // expect empty snapshot
            let second = try #require(await iterator.next())
            let result1 = try second.value(forKey: AbsoluteConfigKey(key1), type: .int)
            let result2 = try second.value(forKey: AbsoluteConfigKey(key2), type: .int)
            #expect(result1.value == nil)
            #expect(result2.value == nil)
        }
    }


    @Test
    mutating func watchValueReturnsNilValueWhenTypeMismatches() async throws {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        let absoluteKey = AbsoluteConfigKey(key)
        provider.setOverride(.int(42), forKey: key)

        // exercise — watch as .string, but the override is .int
        try await provider.watchValue(forKey: absoluteKey, type: .string) { updates in
            var iterator = updates.makeAsyncIterator()

            // expect nil value due to type mismatch
            let first = try #require(await iterator.next())
            #expect(try first.get().value == nil)

            // Update with another int — still mismatches .string
            provider.setOverride(.int(99), forKey: key)

            let second = try #require(await iterator.next())
            #expect(try second.get().value == nil)
        }
    }


    @Test
    mutating func watchValueEmitsInitialAndSubsequentChanges() async throws {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        let absoluteKey = AbsoluteConfigKey(key)
        provider.setOverride(.int(1), forKey: key)

        // exercise
        try await provider.watchValue(forKey: absoluteKey, type: .int) { updates in
            var iterator = updates.makeAsyncIterator()

            // expect initial value
            let first = try #require(await iterator.next())
            #expect(try first.get().value == ConfigValue(.int(1), isSecret: false))

            // Update the override
            provider.setOverride(.int(2), forKey: key)

            // expect updated value
            let second = try #require(await iterator.next())
            #expect(try second.get().value == ConfigValue(.int(2), isSecret: false))
        }
    }


    @Test
    mutating func watchSnapshotEmitsInitialAndSubsequentChanges() async throws {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()

        // exercise
        try await provider.watchSnapshot { updates in
            var iterator = updates.makeAsyncIterator()

            // expect initial empty snapshot
            let first = try #require(await iterator.next())
            #expect(first.providerName != "editorOverrideProvider.name")
            let firstResult = try first.value(forKey: AbsoluteConfigKey(key), type: .string)
            #expect(firstResult.value == nil)

            // Update the override
            provider.setOverride(.string("hello"), forKey: key)

            // expect updated snapshot
            let second = try #require(await iterator.next())
            let secondResult = try second.value(forKey: AbsoluteConfigKey(key), type: .string)
            #expect(secondResult.value == ConfigValue(.string("hello"), isSecret: false))
        }
    }
}


// MARK: - Persistence Tests

struct EditorOverrideProviderPersistenceTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()

    /// Creates a test-specific UserDefaults suite and cleans up the persistence key.
    private func makeTestUserDefaults() -> UserDefaults {
        let suiteName = "devkit.DevConfiguration.test.\(UUID())"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removeObject(forKey: "editorOverrides")
        return userDefaults
    }


    @Test
    mutating func persistThenLoadRoundTripsOverrides() {
        // set up
        let userDefaults = makeTestUserDefaults()
        let key1 = randomConfigKey()
        let key2 = randomConfigKey()
        let content1 = ConfigContent.string(randomAlphanumericString())
        let content2 = ConfigContent.int(randomInt(in: .min ... .max))

        let provider1 = EditorOverrideProvider()
        provider1.setOverride(content1, forKey: key1)
        provider1.setOverride(content2, forKey: key2)
        provider1.persist(to: userDefaults)

        // exercise
        let provider2 = EditorOverrideProvider()
        provider2.load(from: userDefaults)

        // expect
        #expect(provider2.overrides[key1] == content1)
        #expect(provider2.overrides[key2] == content2)
    }


    @Test
    func persistEmptyOverrides() {
        // set up
        let userDefaults = makeTestUserDefaults()
        let provider1 = EditorOverrideProvider()
        provider1.persist(to: userDefaults)

        // exercise
        let provider2 = EditorOverrideProvider()
        provider2.load(from: userDefaults)

        // expect
        #expect(provider2.overrides.isEmpty)
    }


    @Test
    mutating func clearPersistenceRemovesStoredData() {
        // set up
        let userDefaults = makeTestUserDefaults()
        let provider = EditorOverrideProvider()
        provider.setOverride(.bool(true), forKey: randomConfigKey())
        provider.persist(to: userDefaults)

        // exercise
        provider.clearPersistence(from: userDefaults)

        // expect
        let reloaded = EditorOverrideProvider()
        reloaded.load(from: userDefaults)
        #expect(reloaded.overrides.isEmpty)
    }


    @Test
    func loadWithNoStoredDataResultsInEmptyOverrides() {
        // set up
        let userDefaults = makeTestUserDefaults()

        // exercise
        let provider = EditorOverrideProvider()
        provider.load(from: userDefaults)

        // expect
        #expect(provider.overrides.isEmpty)
    }


    @Test
    mutating func loadWithCorruptDataResultsInEmptyOverrides() {
        // set up
        let userDefaults = makeTestUserDefaults()
        let corruptData: [String: Data] = [
            randomAlphanumericString(): randomData()
        ]
        userDefaults.set(corruptData, forKey: "editorOverrides")

        // exercise
        let provider = EditorOverrideProvider()
        provider.load(from: userDefaults)

        // expect
        #expect(provider.overrides.isEmpty)
    }
}
