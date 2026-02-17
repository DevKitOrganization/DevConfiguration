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

    @Test
    mutating func initWithConfigKeyStoresParameters() {
        // set up the test by creating random parameters
        let configKey = randomConfigKey()
        let defaultValue = randomInt(in: .min ... .max)
        let secrecy = randomConfigVariableSecrecy()

        // exercise the test by creating the config variable
        let variable = ConfigVariable(key: configKey, defaultValue: defaultValue, secrecy: secrecy)

        // expect that the variable stores the parameters
        #expect(variable.key == configKey)
        #expect(variable.defaultValue == defaultValue)
        #expect(variable.secrecy == secrecy)
    }


    // MARK: - init(key: String, …)

    @Test
    mutating func initWithStringConvertsKeyAndStoresParameters() {
        // set up the test by creating a dot-separated key string
        let key = randomConfigKey()
        let keyString = key.components.joined(separator: ".")
        let defaultValue = randomInt(in: .min ... .max)
        let secrecy = randomConfigVariableSecrecy()

        // exercise the test by creating the config variable with a string key
        let variable = ConfigVariable(key: keyString, defaultValue: defaultValue, secrecy: secrecy)

        // expect that the string is converted to a ConfigKey and parameters are stored
        #expect(variable.key == ConfigKey(keyString))
        #expect(variable.defaultValue == defaultValue)
        #expect(variable.secrecy == secrecy)
    }
}
