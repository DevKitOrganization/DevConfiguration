//
//  GroupMetadataKey.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 7/22/2026.
//

import Foundation

/// A type representing a logical group for configuration variables in the editor UI.
///
/// Variables with the same group are rendered together in a section with the group's name as the header.
/// Define groups as static members:
///
///     extension ConfigVariableGroup {
///         static let networking = ConfigVariableGroup("Networking")
///         static let featureFlags = ConfigVariableGroup("Feature Flags")
///     }
///
/// Then assign them using metadata:
///
///     ConfigVariable(key: "api.timeout", defaultValue: 30)
///         .metadata(\.group, .networking)
public struct ConfigVariableGroup: Hashable, Sendable, Comparable {
    /// The human-readable name of the group, used as the section header in the editor.
    public let rawValue: String

    /// Creates a new configuration variable group.
    ///
    /// - Parameter rawValue: The human-readable name for this group.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue.localizedStandardCompare(rhs.rawValue) == .orderedAscending
    }
}


private struct GroupMetadataKey: ConfigVariableMetadataKey {
    static let defaultValue: ConfigVariableGroup? = nil
    static let keyDisplayText = localizedString("groupMetadata.keyDisplayText")

    static func displayText(for value: ConfigVariableGroup?) -> String? {
        value?.rawValue
    }
}


extension ConfigVariableMetadata {
    /// The logical group for this configuration variable in the editor UI.
    ///
    /// When set, the editor groups variables with the same group together in a section with the group's name as
    /// the header. Variables with no group appear in a headerless section at the bottom of the list.
    public var group: ConfigVariableGroup? {
        get { self[GroupMetadataKey.self] }
        set { self[GroupMetadataKey.self] = newValue }
    }
}
