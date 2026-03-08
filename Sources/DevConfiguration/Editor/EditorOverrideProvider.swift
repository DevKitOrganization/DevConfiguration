//
//  EditorOverrideProvider.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/7/2026.
//

import Configuration
import Foundation
import OSLog
import Synchronization

/// A configuration provider that stores editor overrides in memory and persists them to UserDefaults.
///
/// `EditorOverrideProvider` is prepended to the reader's provider list when `isEditorEnabled` is true, giving
/// overrides the highest priority. Values are stored in memory for fast access and can be persisted to UserDefaults
/// for durability across app launches.
final class EditorOverrideProvider: Sendable {
    /// The mutable state of the provider, protected by a `Mutex`.
    private struct MutableState: Sendable {
        /// The current overrides keyed by their configuration key.
        var overrides: [ConfigKey: ConfigContent] = [:]

        /// Active watchers for individual configuration keys.
        var valueWatchers: [ConfigKey: [UUID: AsyncStream<ConfigValue?>.Continuation]] = [:]

        /// Active watchers for provider state snapshots.
        var snapshotWatchers: [UUID: AsyncStream<Snapshot>.Continuation] = [:]
    }


    /// An immutable snapshot of the provider's current overrides.
    struct Snapshot: ConfigSnapshot, Sendable {
        let providerName: String
        let overrides: [ConfigKey: ConfigContent]

        func value(forKey key: AbsoluteConfigKey, type: ConfigType) throws -> LookupResult {
            let configKey = ConfigKey(key.components, context: key.context)
            let encodedKey = key.description
            guard let content = overrides[configKey], content.configType == type else {
                return LookupResult(encodedKey: encodedKey, value: nil)
            }

            return LookupResult(encodedKey: encodedKey, value: ConfigValue(content, isSecret: false))
        }
    }


    /// The UserDefaults suite name used for persistence.
    static let suiteName = "devkit.DevConfiguration"

    /// The UserDefaults key under which overrides are stored.
    private static let persistenceKey = "editorOverrides"

    /// The logger used for persistence diagnostics.
    private static let logger = Logger(subsystem: "DevConfiguration", category: "EditorOverrideProvider")

    /// The mutable state protected by a mutex.
    private let mutableState: Mutex<MutableState> = .init(MutableState())
}


// MARK: - Override Management

extension EditorOverrideProvider {
    /// The current overrides.
    var overrides: [ConfigKey: ConfigContent] {
        mutableState.withLock { $0.overrides }
    }


    /// Whether an override exists for the given key.
    ///
    /// - Parameter key: The configuration key to check.
    /// - Returns: `true` if an override is stored for the key.
    func hasOverride(forKey key: ConfigKey) -> Bool {
        mutableState.withLock { $0.overrides[key] != nil }
    }


    /// Sets an override value for the given key.
    ///
    /// If the new content is the same as the existing override, no change is made and watchers are not notified.
    ///
    /// - Parameters:
    ///   - content: The override content value.
    ///   - key: The configuration key to override.
    func setOverride(_ content: ConfigContent, forKey key: ConfigKey) {
        var valueContinuations: [UUID: AsyncStream<ConfigValue?>.Continuation]?
        var snapshotUpdate: ([UUID: AsyncStream<Snapshot>.Continuation], Snapshot)?

        mutableState.withLock { state in
            guard state.overrides[key] != content else {
                return
            }

            state.overrides[key] = content
            valueContinuations = state.valueWatchers[key]

            if !state.snapshotWatchers.isEmpty {
                snapshotUpdate = (state.snapshotWatchers, makeSnapshot(from: state))
            }
        }

        let configValue = ConfigValue(content, isSecret: false)
        if let valueContinuations {
            for (_, continuation) in valueContinuations {
                continuation.yield(configValue)
            }
        }

        if let (continuations, snapshot) = snapshotUpdate {
            for (_, continuation) in continuations {
                continuation.yield(snapshot)
            }
        }
    }


    /// Removes the override for the given key.
    ///
    /// If no override exists for the key, no change is made and watchers are not notified.
    ///
    /// - Parameter key: The configuration key whose override should be removed.
    func removeOverride(forKey key: ConfigKey) {
        var valueContinuations: [UUID: AsyncStream<ConfigValue?>.Continuation]?
        var snapshotUpdate: ([UUID: AsyncStream<Snapshot>.Continuation], Snapshot)?

        mutableState.withLock { state in
            guard state.overrides.removeValue(forKey: key) != nil else {
                return
            }

            valueContinuations = state.valueWatchers[key]

            if !state.snapshotWatchers.isEmpty {
                snapshotUpdate = (state.snapshotWatchers, makeSnapshot(from: state))
            }
        }

        if let valueContinuations {
            for (_, continuation) in valueContinuations {
                continuation.yield(nil)
            }
        }

        if let (continuations, snapshot) = snapshotUpdate {
            for (_, continuation) in continuations {
                continuation.yield(snapshot)
            }
        }
    }


    /// Removes all overrides.
    ///
    /// Notifies all active value watchers with `nil` and all snapshot watchers with an empty snapshot.
    func removeAllOverrides() {
        var allValueContinuations: [[UUID: AsyncStream<ConfigValue?>.Continuation]] = []
        var snapshotUpdate: ([UUID: AsyncStream<Snapshot>.Continuation], Snapshot)?

        mutableState.withLock { state in
            guard !state.overrides.isEmpty else {
                return
            }

            for key in state.overrides.keys {
                if let watchers = state.valueWatchers[key] {
                    allValueContinuations.append(watchers)
                }
            }

            state.overrides.removeAll()

            if !state.snapshotWatchers.isEmpty {
                snapshotUpdate = (state.snapshotWatchers, makeSnapshot(from: state))
            }
        }

        for watchers in allValueContinuations {
            for (_, continuation) in watchers {
                continuation.yield(nil)
            }
        }

        if let (continuations, snapshot) = snapshotUpdate {
            for (_, continuation) in continuations {
                continuation.yield(snapshot)
            }
        }
    }


    /// Creates a snapshot from the current mutable state.
    ///
    /// Must be called while the mutex is locked.
    private func makeSnapshot(from state: MutableState) -> Snapshot {
        Snapshot(providerName: providerName, overrides: state.overrides)
    }
}


// MARK: - Persistence

extension EditorOverrideProvider {
    /// Loads persisted overrides from the given UserDefaults into memory.
    ///
    /// Any entries that fail to decode are silently skipped. This method is intended to be called once during setup,
    /// before the provider is shared with other components.
    ///
    /// - Parameter userDefaults: The UserDefaults instance to load from.
    func load(from userDefaults: UserDefaults) {
        guard let stored = userDefaults.dictionary(forKey: Self.persistenceKey) as? [String: Data] else {
            return
        }

        let decoder = JSONDecoder()
        var loadedOverrides: [ConfigKey: ConfigContent] = [:]
        for (keyString, data) in stored {
            do {
                let content = try decoder.decode(ConfigContent.self, from: data)
                loadedOverrides[ConfigKey(keyString)] = content
            } catch {
                Self.logger.error("Failed to decode persisted override for key '\(keyString)': \(error)")
            }
        }

        mutableState.withLock { state in
            state.overrides = loadedOverrides
        }
    }


    /// Persists the current overrides to the given UserDefaults.
    ///
    /// Each override is JSON-encoded individually. The resulting dictionary is stored under the persistence key.
    ///
    /// - Parameter userDefaults: The UserDefaults instance to persist to.
    func persist(to userDefaults: UserDefaults) {
        let currentOverrides = overrides
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        var stored: [String: Data] = [:]
        for (key, content) in currentOverrides {
            do {
                stored[key.description] = try encoder.encode(content)
            } catch {
                // This should never happen
                Self.logger.error("Failed to encode override for key '\(key)': \(error)")
            }
        }

        userDefaults.set(stored, forKey: Self.persistenceKey)
    }


    /// Removes all persisted overrides from the given UserDefaults.
    ///
    /// This does not affect the in-memory overrides.
    ///
    /// - Parameter userDefaults: The UserDefaults instance to clear.
    func clearPersistence(from userDefaults: UserDefaults) {
        userDefaults.removeObject(forKey: Self.persistenceKey)
    }
}


// MARK: - Value Watching

extension EditorOverrideProvider {
    /// Adds a value watcher continuation for the given key.
    ///
    /// The continuation is immediately yielded the current value for the key.
    private func addValueContinuation(
        _ continuation: AsyncStream<ConfigValue?>.Continuation,
        id: UUID,
        forKey key: ConfigKey
    ) {
        mutableState.withLock { state in
            state.valueWatchers[key, default: [:]][id] = continuation
            let value = state.overrides[key].map { ConfigValue($0, isSecret: false) }
            continuation.yield(value)
        }
    }


    /// Removes the value watcher continuation for the given identifier and key.
    private func removeValueContinuation(id: UUID, forKey key: ConfigKey) {
        mutableState.withLock { state in
            state.valueWatchers[key]?[id] = nil
        }
    }


    /// Adds a snapshot watcher continuation.
    ///
    /// The continuation is immediately yielded the current snapshot.
    private func addSnapshotContinuation(
        _ continuation: AsyncStream<Snapshot>.Continuation,
        id: UUID
    ) {
        mutableState.withLock { state in
            state.snapshotWatchers[id] = continuation
            continuation.yield(makeSnapshot(from: state))
        }
    }


    /// Removes the snapshot watcher continuation for the given identifier.
    private func removeSnapshotContinuation(id: UUID) {
        mutableState.withLock { state in
            state.snapshotWatchers[id] = nil
        }
    }
}


// MARK: - ConfigProvider

extension EditorOverrideProvider: ConfigProvider {
    var providerName: String {
        "Editor"
    }


    func value(forKey key: AbsoluteConfigKey, type: ConfigType) throws -> LookupResult {
        mutableState.withLock { state in
            let configKey = ConfigKey(key.components, context: key.context)
            let encodedKey = key.description

            guard let content = state.overrides[configKey], content.configType == type else {
                return LookupResult(encodedKey: encodedKey, value: nil)
            }

            return LookupResult(encodedKey: encodedKey, value: ConfigValue(content, isSecret: false))
        }
    }


    func fetchValue(forKey key: AbsoluteConfigKey, type: ConfigType) async throws -> LookupResult {
        try value(forKey: key, type: type)
    }


    // swift-format-ignore
    //
    // Note:
    //     The swift-format-ignore rule here is due to a bug in swift-format where it is putting a space between
    //     nonisolated and (nonsending). This causes a compilation error. We cannot disable formatting for just a
    //     parameter, so we have to disable it for the entire function.
    func watchValue<Return: ~Copyable>(
        forKey key: AbsoluteConfigKey,
        type: ConfigType,
        updatesHandler: nonisolated(nonsending)(
            _ updates: ConfigUpdatesAsyncSequence<Result<LookupResult, any Error>, Never>
        ) async throws -> Return
    ) async throws -> Return {
        let configKey = ConfigKey(key.components, context: key.context)
        let encodedKey = key.description
        let (stream, continuation) = AsyncStream<ConfigValue?>.makeStream(bufferingPolicy: .bufferingNewest(1))
        let id = UUID()
        addValueContinuation(continuation, id: id, forKey: configKey)
        defer {
            removeValueContinuation(id: id, forKey: configKey)
        }

        return try await updatesHandler(
            ConfigUpdatesAsyncSequence(
                stream.map { (value: ConfigValue?) -> Result<LookupResult, any Error> in
                    guard let value, value.content.configType == type else {
                        return .success(LookupResult(encodedKey: encodedKey, value: nil))
                    }

                    return .success(LookupResult(encodedKey: encodedKey, value: value))
                }
            )
        )
    }


    func snapshot() -> any ConfigSnapshot {
        mutableState.withLock { makeSnapshot(from: $0) }
    }


    // swift-format-ignore
    //
    // Note:
    //     The swift-format-ignore rule here is due to a bug in swift-format where it is putting a space between
    //     nonisolated and (nonsending). This causes a compilation error. We cannot disable formatting for just a
    //     parameter, so we have to disable it for the entire function.
    func watchSnapshot<Return: ~Copyable>(
        updatesHandler: nonisolated(nonsending)(
            _ updates: ConfigUpdatesAsyncSequence<any ConfigSnapshot, Never>
        ) async throws -> Return
    ) async throws -> Return {
        let (stream, continuation) = AsyncStream<Snapshot>.makeStream(bufferingPolicy: .bufferingNewest(1))
        let id = UUID()
        addSnapshotContinuation(continuation, id: id)
        defer {
            removeSnapshotContinuation(id: id)
        }

        return try await updatesHandler(ConfigUpdatesAsyncSequence(stream.map { $0 }))
    }
}
