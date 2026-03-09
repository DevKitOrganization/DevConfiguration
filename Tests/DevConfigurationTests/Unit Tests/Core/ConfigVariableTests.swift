//
//  ConfigVariableTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 2/16/2026.
//

import Configuration
import DevConfiguration
import DevTesting
import Testing

struct ConfigVariableTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    // MARK: - init(key: ConfigKey, …)

    @Test(arguments: [false, true])
    mutating func initWithConfigKeyStoresParameters(isSecret: Bool) {
        // set up
        let configKey = randomConfigKey()
        let defaultValue = randomInt(in: .min ... .max)

        // exercise
        let variable = ConfigVariable(key: configKey, defaultValue: defaultValue, isSecret: isSecret)

        // expect
        #expect(variable.key == configKey)
        #expect(variable.defaultValue == defaultValue)
        #expect(variable.isSecret == isSecret)
    }


    // MARK: - metadata(_:_:)

    @Test
    mutating func metadataMethodSetsMetadataAndReturnsNewInstance() {
        // set up the test by creating a config variable
        let original = ConfigVariable(key: randomConfigKey(), defaultValue: randomInt(in: .min ... .max))
        let metadataValue = randomAlphanumericString()

        // exercise the test by setting metadata using the fluent method
        let updated = original.metadata(\.testProject, metadataValue)

        // expect that the updated variable has the metadata and original is unchanged
        #expect(updated.testProject == metadataValue)
        #expect(original.testProject == nil)
    }


    @Test
    mutating func metadataMethodChainingWorks() {
        // set up the test by creating a config variable and metadata values
        let variable = ConfigVariable(key: randomConfigKey(), defaultValue: randomInt(in: .min ... .max))
        let project = randomAlphanumericString()
        let team = randomAlphanumericString()

        // exercise the test by chaining multiple metadata calls
        let updated = variable.metadata(\.testProject, project)
            .metadata(\.testTeam, team)

        // expect that both metadata values are set
        #expect(updated.testProject == project)
        #expect(updated.testTeam == team)
    }


    // MARK: - Dynamic Member Subscript

    @Test
    mutating func dynamicMemberSubscriptGetAndSet() {
        // set up the test by creating a config variable
        var variable = ConfigVariable(key: randomConfigKey(), defaultValue: randomInt(in: .min ... .max))
        let project = randomAlphanumericString()

        // exercise the test by setting metadata via dynamic member subscript
        variable.testProject = project

        // expect that the metadata value is set and can be retrieved
        #expect(variable.testProject == project)
    }
}
