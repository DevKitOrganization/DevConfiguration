//
//  TestConfigVariableMetadataKeys.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/5/2026.
//

@testable import DevConfiguration

// MARK: - Metadata Keys

enum MetadataEnum: String, CaseIterable, Sendable {
    case valueA
    case valueB
}


struct EnumMetadataKey: ConfigVariableMetadataKey {
    static let defaultValue = MetadataEnum.valueA
    static let keyDisplayText = "EnumKey"
}


struct IntMetadataKey: ConfigVariableMetadataKey {
    static let defaultValue = 0
    static let keyDisplayText = "IntKey"
}


struct OptionalEnumMetadataKey: ConfigVariableMetadataKey {
    static let defaultValue: MetadataEnum? = nil
    static let keyDisplayText = "OptionalEnumKey"
}


struct OptionalIntMetadataKey: ConfigVariableMetadataKey {
    static let defaultValue: Int? = nil
    static let keyDisplayText = "OptionalIntKey"
}


struct StringMetadataKey: ConfigVariableMetadataKey {
    static let defaultValue: String? = nil
    static let keyDisplayText = "StringKey"
}


struct TestProjectMetadataKey: ConfigVariableMetadataKey {
    static let defaultValue: String? = nil
    static let keyDisplayText = "TestProject"
}


struct TestTeamMetadataKey: ConfigVariableMetadataKey {
    static let defaultValue: String? = nil
    static let keyDisplayText = "TestTeam"
}


// MARK: - ConfigVariableMetadata Extensions

extension ConfigVariableMetadata {
    var testProject: String? {
        get { self[TestProjectMetadataKey.self] }
        set { self[TestProjectMetadataKey.self] = newValue }
    }

    var testTeam: String? {
        get { self[TestTeamMetadataKey.self] }
        set { self[TestTeamMetadataKey.self] = newValue }
    }
}
