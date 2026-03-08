//
//  RegisteredConfigVariableTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/5/2026.
//

import Configuration
import DevTesting
import Testing

@testable import DevConfiguration

struct RegisteredConfigVariableTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func dynamicMemberLookupReturnsMetadataValue() {
        // set up
        var metadata = ConfigVariableMetadata()
        let project = randomAlphanumericString()
        metadata[TestProjectMetadataKey.self] = project

        let variable = RegisteredConfigVariable(
            key: randomConfigKey(),
            defaultContent: randomConfigContent(),
            isSecret: randomBool(),
            metadata: metadata,
            editorControl: .none,
            parse: nil
        )

        // expect
        #expect(variable.testProject == project)
    }


    @Test
    mutating func dynamicMemberLookupReturnsDefaultWhenNotSet() {
        // set up
        let variable = RegisteredConfigVariable(
            key: randomConfigKey(),
            defaultContent: randomConfigContent(),
            isSecret: randomBool(),
            metadata: ConfigVariableMetadata(),
            editorControl: .none,
            parse: nil
        )

        // expect
        #expect(variable.testProject == nil)
    }
}
