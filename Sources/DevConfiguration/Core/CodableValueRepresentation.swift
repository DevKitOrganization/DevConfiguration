//
//  CodableValueRepresentation.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/5/2026.
//

import Configuration
import Foundation

/// Describes how a `Codable` configuration value is represented within the configuration provider.
///
/// This type determines which `ConfigContent` case the reader pulls from when decoding a `Codable` value, and which
/// case the encoder writes to when storing a value for registration.
///
/// `CodableValueRepresentation` is a struct with a private backing enum, allowing new representations to be added in
/// the future without breaking existing consumers.
public struct CodableValueRepresentation: Sendable {
    /// The underlying kinds of representations that a `Codable` value can be.
    ///
    /// This enum exists so that we can add new representations without breaking the public API.
    private enum Kind: Sendable {
        /// Indicates that the value is stored as a string with the specified encoding.
        case string(encoding: String.Encoding)

        /// Indicates that the value is stored as bytes.
        case data
    }


    /// The underlying kind of this representation.
    private let kind: Kind


    /// The value is stored as a `ConfigContent.string`.
    ///
    /// The given encoding is used to convert between `String` and `Data` for the decoder and encoder.
    ///
    /// - Parameter encoding: The string encoding to use. Defaults to `.utf8`.
    public static func string(encoding: String.Encoding = .utf8) -> CodableValueRepresentation {
        CodableValueRepresentation(kind: .string(encoding: encoding))
    }


    /// The value is stored as `ConfigContent.bytes`.
    public static var data: CodableValueRepresentation {
        CodableValueRepresentation(kind: .data)
    }


    /// Whether this representation uses string-backed storage.
    var isStringBacked: Bool {
        switch kind {
        case .string:
            true
        case .data:
            false
        }
    }


    /// Reads raw data synchronously from the reader based on this representation.
    ///
    /// For string-backed representations, this reads a string value and converts it to `Data` using the representation’s
    /// encoding. For data-backed representations, this reads a byte array and wraps it in `Data`.
    ///
    /// - Parameters:
    ///   - reader: The configuration reader to read from.
    ///   - key: The configuration key to look up.
    ///   - isSecret: Whether the value should be treated as a secret for access reporting.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The raw data for the key, or `nil` if the key was not found.
    func readData(
        from reader: ConfigReader,
        forKey key: ConfigKey,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) -> Data? {
        switch kind {
        case .string(let encoding):
            reader.string(forKey: key, isSecret: isSecret, fileID: fileID, line: line)?
                .data(using: encoding)
        case .data:
            reader.bytes(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
                .map { Data($0) }
        }
    }


    /// Fetches raw data asynchronously from the reader based on this representation.
    ///
    /// This is the async counterpart of ``readData(from:forKey:isSecret:fileID:line:)``.
    ///
    /// - Parameters:
    ///   - reader: The configuration reader to fetch from.
    ///   - key: The configuration key to look up.
    ///   - isSecret: Whether the value should be treated as a secret for access reporting.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    /// - Returns: The raw data for the key, or `nil` if the key was not found.
    func fetchData(
        from reader: ConfigReader,
        forKey key: ConfigKey,
        isSecret: Bool,
        fileID: String,
        line: UInt
    ) async throws -> Data? {
        switch kind {
        case .string(let encoding):
            try await reader.fetchString(forKey: key, isSecret: isSecret, fileID: fileID, line: line)?
                .data(using: encoding)
        case .data:
            try await reader.fetchBytes(forKey: key, isSecret: isSecret, fileID: fileID, line: line)
                .map { Data($0) }
        }
    }


    /// Watches for raw data changes from the reader based on this representation.
    ///
    /// Each time the underlying configuration value changes, `onUpdate` is called with the new raw data (or `nil` if the
    /// key is no longer present).
    ///
    /// - Parameters:
    ///   - reader: The configuration reader to watch.
    ///   - key: The configuration key to watch.
    ///   - isSecret: Whether the value should be treated as a secret for access reporting.
    ///   - fileID: The source file identifier for access reporting.
    ///   - line: The source line number for access reporting.
    ///   - onUpdate: A closure invoked with the updated raw data each time the value changes.
    func watchData(
        from reader: ConfigReader,
        forKey key: ConfigKey,
        isSecret: Bool,
        fileID: String,
        line: UInt,
        onUpdate: @Sendable (Data?) -> Void
    ) async throws {
        switch kind {
        case .string(let encoding):
            try await reader.watchString(forKey: key, isSecret: isSecret, fileID: fileID, line: line) { (updates) in
                for await value in updates {
                    onUpdate(value?.data(using: encoding))
                }
            }
        case .data:
            try await reader.watchBytes(forKey: key, isSecret: isSecret, fileID: fileID, line: line) { (updates) in
                for await value in updates {
                    onUpdate(value.map { Data($0) })
                }
            }
        }
    }
}
