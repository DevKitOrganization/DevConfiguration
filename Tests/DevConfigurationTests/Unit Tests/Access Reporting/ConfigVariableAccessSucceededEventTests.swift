//
//  ConfigVariableAccessSucceededEventTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 2/16/2026.
//

import Configuration
import DevConfiguration
import DevTesting
import Testing

struct ConfigVariableAccessSucceededEventTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    // MARK: - init

    @Test(arguments: [false, true])
    mutating func initStoresParameters(hasProviderName: Bool) {
        // set up the test by creating random parameters
        let key = randomAbsoluteConfigKey()
        let value = randomConfigValue()
        let providerName = hasProviderName ? randomAlphanumericString() : nil

        // exercise the test by creating the event
        let event = ConfigVariableAccessSucceededEvent(key: key, value: value, providerName: providerName)

        // expect that the event stores the parameters
        #expect(event.key == key)
        #expect(event.value == value)
        #expect(event.providerName == providerName)
    }
}
