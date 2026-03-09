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
            destinationTypeName: randomAlphanumericString(),
            editorControl: .none,
            parse: nil
        )

        // expect
        #expect(variable.testProject == project)
    }


    @Test(
        arguments: [
            ("Int", "Int"),
            ("CardSuit", "CardSuit"),
            ("Array<Int>", "[Int]"),
            ("Optional<String>", "String?"),
            ("Dictionary<String, Int>", "[String: Int]"),
            ("Optional<Array<String>>", "[String]?"),
            ("Array<Optional<Int>>", "[Int?]"),
            ("Dictionary<String, Array<Int>>", "[String: [Int]]"),
            ("Array<Dictionary<String, Optional<Int>>>", "[[String: Int?]]"),
            ("[Int]", "[Int]"),
            ("Array<Int", "Array<Int"),
            ("Dictionary<String, Int", "Dictionary<String, Int"),
            ("Optional<String", "Optional<String"),
            ("Dictionary<Int>", "Dictionary<Int>"),
            ("Dictionary<Foo<Int>>", "Dictionary<Foo<Int>>"),
            ("Double", "Float64"),
            ("Array<Double>", "[Float64]"),
            ("Dictionary<Double, Array<Double>>", "[Float64: [Float64]]"),
            ("DoubleMeaning", "DoubleMeaning"),
        ]
    )
    mutating func initNormalizesDestinationTypeName(
        input: String,
        expected: String
    ) {
        // set up
        let variable = RegisteredConfigVariable(
            key: randomConfigKey(),
            defaultContent: randomConfigContent(),
            isSecret: randomBool(),
            metadata: ConfigVariableMetadata(),
            destinationTypeName: input,
            editorControl: .none,
            parse: nil
        )

        // expect
        #expect(variable.destinationTypeName == expected)
    }


    @Test
    mutating func dynamicMemberLookupReturnsDefaultWhenNotSet() {
        // set up
        let variable = RegisteredConfigVariable(
            key: randomConfigKey(),
            defaultContent: randomConfigContent(),
            isSecret: randomBool(),
            metadata: ConfigVariableMetadata(),
            destinationTypeName: randomAlphanumericString(),
            editorControl: .none,
            parse: nil
        )

        // expect
        #expect(variable.testProject == nil)
    }
}
