//
//  VariableName.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 7/12/25.
//

import Foundation

/// The name of a variable as defined by the configuration source.
public struct VariableName: Codable, Hashable, Sendable {
    public let rawValue: String


    /// Creates a new `VariableName` instance.
    ///
    /// - Parameter rawValue: The variable's name.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

// MARK: - RawRepresentable Conformance

extension VariableName: RawRepresentable {
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}


// MARK: - ExpressibleByStringLiteral Conformance

extension VariableName: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}


// MARK: - CustomStringConvertible Conformance

extension VariableName: CustomStringConvertible {
    public var description: String {
        return rawValue
    }
}
