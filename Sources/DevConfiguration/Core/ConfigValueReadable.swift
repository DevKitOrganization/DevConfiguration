//
//  ConfigValueReadable.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 2/16/2026.
//

import Configuration
import Foundation

/// A type of that can be read by a ConfigReader.
///
/// This protocol provides the bridge between `ConfigVariableReader` and `ConfigReader`, allowing generic
/// implementations that dispatch to the appropriate type-specific methods.
public protocol ConfigValueReadable: Sendable {
    /// Gets the required value for the specified key from the reader.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - reader: The configuration reader.
    ///   - isSecret: Whether the value is secret.
    ///   - fileID: The source file identifier.
    ///   - line: The source line number.
    /// - Returns: The configuration value.
    /// - Throws: An error if the value cannot be retrieved.
    static func requiredValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) throws -> Self

    /// Asynchronously fetches the required value for the specified key from the reader.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - reader: The configuration reader.
    ///   - isSecret: Whether the value is secret.
    ///   - fileID: The source file identifier.
    ///   - line: The source line number.
    /// - Returns: The configuration value.
    /// - Throws: An error if the value cannot be fetched.
    static func fetchRequiredValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) async throws -> Self

    /// Watches for updates to the value for the specified key, using a default if the key is not found.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - reader: The configuration reader.
    ///   - isSecret: Whether the value is secret.
    ///   - defaultValue: The default value to use if the key is not found.
    ///   - fileID: The source file identifier.
    ///   - line: The source line number.
    ///   - updatesHandler: A closure that handles the async sequence of updates.
    /// - Returns: The result produced by the handler.
    static func watchValue<Return: ~Copyable>(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        default defaultValue: Self,
        fileID: String,
        line: UInt,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<Self, Never>) async throws -> Return
    ) async throws -> Return


    /// Gets the required array value for the specified key from the reader.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - reader: The configuration reader.
    ///   - isSecret: Whether the value is secret.
    ///   - fileID: The source file identifier.
    ///   - line: The source line number.
    /// - Returns: The configuration array value.
    /// - Throws: An error if the value cannot be retrieved.
    static func requiredArrayValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) throws -> [Self]

    /// Asynchronously fetches the required array value for the specified key from the reader.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - reader: The configuration reader.
    ///   - isSecret: Whether the value is secret.
    ///   - fileID: The source file identifier.
    ///   - line: The source line number.
    /// - Returns: The configuration array value.
    /// - Throws: An error if the value cannot be fetched.
    static func fetchRequiredArrayValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) async throws -> [Self]

    /// Watches for updates to the array value for the specified key, using a default if the key is not found.
    ///
    /// - Parameters:
    ///   - key: The configuration key.
    ///   - reader: The configuration reader.
    ///   - isSecret: Whether the value is secret.
    ///   - defaultValue: The default value to use if the key is not found.
    ///   - fileID: The source file identifier.
    ///   - line: The source line number.
    ///   - updatesHandler: A closure that handles the async sequence of updates.
    /// - Returns: The result produced by the handler.
    static func watchArrayValue<Return>(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        default defaultValue: [Self],
        fileID: String,
        line: UInt,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<[Self], Never>) async throws -> Return
    ) async throws -> Return where Return: ~Copyable
}


// MARK: - Bool Conformance

extension Bool: ConfigValueReadable {
    public static func requiredValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) throws -> Bool {
        try reader.requiredBool(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
    }


    public static func fetchRequiredValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) async throws -> Bool {
        try await reader.fetchRequiredBool(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
    }


    public static func watchValue<Return>(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        default defaultValue: Bool,
        fileID: String,
        line: UInt,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<Bool, Never>) async throws -> Return
    ) async throws -> Return where Return: ~Copyable {
        try await reader.watchBool(
            forKey: key,
            isSecret: isSecret,
            default: defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }


    public static func requiredArrayValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) throws -> [Bool] {
        try reader.requiredBoolArray(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
    }


    public static func fetchRequiredArrayValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) async throws -> [Bool] {
        try await reader.fetchRequiredBoolArray(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
    }


    public static func watchArrayValue<Return>(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        default defaultValue: [Bool],
        fileID: String,
        line: UInt,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<[Bool], Never>) async throws -> Return
    ) async throws -> Return where Return: ~Copyable {
        try await reader.watchBoolArray(
            forKey: key,
            isSecret: isSecret,
            default: defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }
}


// MARK: - Data Conformance

extension Data: ConfigValueReadable {
    public static func requiredValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) throws -> Data {
        Data(try reader.requiredBytes(forKey: key, isSecret: isSecret, fileID: fileID, line: line))
    }


    public static func fetchRequiredValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) async throws -> Data {
        Data(try await reader.fetchRequiredBytes(forKey: key, isSecret: isSecret, fileID: fileID, line: line))
    }


    public static func watchValue<Return>(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        default defaultValue: Data,
        fileID: String,
        line: UInt,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<Data, Never>) async throws -> Return
    ) async throws -> Return where Return: ~Copyable {
        try await reader.watchBytes(
            forKey: key,
            isSecret: isSecret,
            default: Array(defaultValue),
            fileID: fileID,
            line: line
        ) { (updates) in
            try await updatesHandler(ConfigUpdatesAsyncSequence(updates.map { Data($0) }))
        }
    }


    public static func requiredArrayValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) throws -> [Data] {
        try reader.requiredByteChunkArray(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
            .map { Data($0) }
    }


    public static func fetchRequiredArrayValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) async throws -> [Data] {
        try await reader.fetchRequiredByteChunkArray(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
            .map { Data($0) }
    }


    public static func watchArrayValue<Return: ~Copyable>(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        default defaultValue: [Data],
        fileID: String,
        line: UInt,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<[Data], Never>) async throws -> Return
    ) async throws -> Return where Return: ~Copyable {
        try await reader.watchByteChunkArray(
            forKey: key,
            isSecret: isSecret,
            default: defaultValue.map { Array($0) },
            fileID: fileID,
            line: line
        ) { (updates) in
            try await updatesHandler(ConfigUpdatesAsyncSequence(updates.map { $0.map { Data($0) } }))
        }
    }
}


// MARK: - Float64 Conformance

extension Float64: ConfigValueReadable {
    public static func requiredValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) throws -> Float64 {
        try reader.requiredDouble(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
    }


    public static func fetchRequiredValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) async throws -> Float64 {
        try await reader.fetchRequiredDouble(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
    }


    public static func watchValue<Return>(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        default defaultValue: Float64,
        fileID: String,
        line: UInt,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<Float64, Never>) async throws -> Return
    ) async throws -> Return where Return: ~Copyable {
        try await reader.watchDouble(
            forKey: key,
            isSecret: isSecret,
            default: defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }


    public static func requiredArrayValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) throws -> [Float64] {
        try reader.requiredDoubleArray(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
    }


    public static func fetchRequiredArrayValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) async throws -> [Float64] {
        try await reader.fetchRequiredDoubleArray(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
    }


    public static func watchArrayValue<Return: ~Copyable>(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        default defaultValue: [Float64],
        fileID: String,
        line: UInt,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<[Float64], Never>) async throws -> Return
    ) async throws -> Return where Return: ~Copyable {
        try await reader.watchDoubleArray(
            forKey: key,
            isSecret: isSecret,
            default: defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }
}


// MARK: - Int Conformance

extension Int: ConfigValueReadable {
    public static func requiredValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) throws -> Int {
        try reader.requiredInt(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
    }


    public static func fetchRequiredValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) async throws -> Int {
        try await reader.fetchRequiredInt(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
    }


    public static func watchValue<Return>(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        default defaultValue: Int,
        fileID: String,
        line: UInt,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<Int, Never>) async throws -> Return
    ) async throws -> Return where Return: ~Copyable {
        try await reader.watchInt(
            forKey: key,
            isSecret: isSecret,
            default: defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }


    public static func requiredArrayValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) throws -> [Int] {
        try reader.requiredIntArray(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
    }


    public static func fetchRequiredArrayValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) async throws -> [Int] {
        try await reader.fetchRequiredIntArray(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
    }


    public static func watchArrayValue<Return: ~Copyable>(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        default defaultValue: [Int],
        fileID: String,
        line: UInt,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<[Int], Never>) async throws -> Return
    ) async throws -> Return where Return: ~Copyable {
        try await reader.watchIntArray(
            forKey: key,
            isSecret: isSecret,
            default: defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }
}


// MARK: - String Conformance

extension String: ConfigValueReadable {
    public static func requiredValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) throws -> String {
        try reader.requiredString(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
    }


    public static func fetchRequiredValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) async throws -> String {
        try await reader.fetchRequiredString(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
    }


    public static func watchValue<Return>(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        default defaultValue: String,
        fileID: String,
        line: UInt,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<String, Never>) async throws -> Return
    ) async throws -> Return where Return: ~Copyable {
        try await reader.watchString(
            forKey: key,
            isSecret: isSecret,
            default: defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }


    public static func requiredArrayValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) throws -> [String] {
        try reader.requiredStringArray(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
    }


    public static func fetchRequiredArrayValue(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) async throws -> [String] {
        try await reader.fetchRequiredStringArray(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
    }


    public static func watchArrayValue<Return: ~Copyable>(
        forKey key: ConfigKey,
        reader: ConfigReader,
        isSecret: Bool,
        default defaultValue: [String],
        fileID: String,
        line: UInt,
        updatesHandler: (_ updates: ConfigUpdatesAsyncSequence<[String], Never>) async throws -> Return
    ) async throws -> Return where Return: ~Copyable {
        try await reader.watchStringArray(
            forKey: key,
            isSecret: isSecret,
            default: defaultValue,
            fileID: fileID,
            line: line,
            updatesHandler: updatesHandler
        )
    }
}
