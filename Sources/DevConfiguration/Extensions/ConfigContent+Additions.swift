//
//  ConfigContent+Additions.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/7/2026.
//

import Configuration
import Foundation

extension ConfigContent {
    /// The configuration type of this content.
    ///
    /// This mirrors the `package`-scoped `type` property on `ConfigContent` in swift-configuration, which is not
    /// accessible from this module.
    var configType: ConfigType {
        switch self {
        case .string: .string
        case .int: .int
        case .double: .double
        case .bool: .bool
        case .bytes: .bytes
        case .stringArray: .stringArray
        case .intArray: .intArray
        case .doubleArray: .doubleArray
        case .boolArray: .boolArray
        case .byteChunkArray: .byteChunkArray
        }
    }
}


// MARK: - Type Display Name

extension ConfigContent {
    /// A human-readable name for this content's type.
    var typeDisplayName: String {
        switch self {
        case .bool: "Bool"
        case .int: "Int"
        case .double: "Float64"
        case .string: "String"
        case .bytes: "Data"
        case .boolArray: "[Bool]"
        case .intArray: "[Int]"
        case .doubleArray: "[Float64]"
        case .stringArray: "[String]"
        case .byteChunkArray: "[Data]"
        }
    }
}


// MARK: - Display String

extension ConfigContent {
    /// A human-readable string representation of this content's value.
    ///
    /// Numeric values are formatted using locale-aware formatters. Array values are formatted as narrow-width lists.
    /// Byte values use the memory byte count style.
    var displayString: String {
        switch self {
        case .bool(let value):
            String(value)
        case .int(let value):
            value.formatted()
        case .double(let value):
            value.formatted()
        case .string(let value):
            value
        case .bytes(let value):
            value.count.formatted(.byteCount(style: .memory))
        case .boolArray(let value):
            value.map(String.init).formatted(.list(type: .and, width: .narrow))
        case .intArray(let value):
            value.map { $0.formatted() }.formatted(.list(type: .and, width: .narrow))
        case .doubleArray(let value):
            value.map { $0.formatted() }.formatted(.list(type: .and, width: .narrow))
        case .stringArray(let value):
            value.formatted(.list(type: .and, width: .narrow))
        case .byteChunkArray(let value):
            value.map { $0.count.formatted(.byteCount(style: .memory)) }
                .formatted(.list(type: .and, width: .narrow))
        }
    }
}


// MARK: - Codable

extension ConfigContent: @retroactive Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }


    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(configType.rawValue, forKey: .type)

        switch self {
        case .string(let value):
            try container.encode(value, forKey: .value)
        case .int(let value):
            try container.encode(value, forKey: .value)
        case .double(let value):
            try container.encode(value, forKey: .value)
        case .bool(let value):
            try container.encode(value, forKey: .value)
        case .bytes(let value):
            try container.encode(value, forKey: .value)
        case .stringArray(let value):
            try container.encode(value, forKey: .value)
        case .intArray(let value):
            try container.encode(value, forKey: .value)
        case .doubleArray(let value):
            try container.encode(value, forKey: .value)
        case .boolArray(let value):
            try container.encode(value, forKey: .value)
        case .byteChunkArray(let value):
            try container.encode(value, forKey: .value)
        }
    }


    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeString = try container.decode(String.self, forKey: .type)
        guard let type = ConfigType(rawValue: typeString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown config type: \(typeString)"
            )
        }

        switch type {
        case .string:
            self = .string(try container.decode(String.self, forKey: .value))
        case .int:
            self = .int(try container.decode(Int.self, forKey: .value))
        case .double:
            self = .double(try container.decode(Double.self, forKey: .value))
        case .bool:
            self = .bool(try container.decode(Bool.self, forKey: .value))
        case .bytes:
            self = .bytes(try container.decode([UInt8].self, forKey: .value))
        case .stringArray:
            self = .stringArray(try container.decode([String].self, forKey: .value))
        case .intArray:
            self = .intArray(try container.decode([Int].self, forKey: .value))
        case .doubleArray:
            self = .doubleArray(try container.decode([Double].self, forKey: .value))
        case .boolArray:
            self = .boolArray(try container.decode([Bool].self, forKey: .value))
        case .byteChunkArray:
            self = .byteChunkArray(try container.decode([[UInt8]].self, forKey: .value))
        }
    }
}
