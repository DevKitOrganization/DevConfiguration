//
//  ConfigVariableAccessFailedEventTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 2/16/2026.
//

import Configuration
import DevConfiguration
import DevTesting
import Testing

struct ConfigVariableAccessFailedEventTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    // MARK: - init

    @Test
    mutating func initStoresParameters() {
        // set up the test by creating random parameters
        let key = randomAbsoluteConfigKey()
        let error = randomError()

        // exercise the test by creating the event
        let event = ConfigVariableAccessFailedEvent(key: key, error: error)

        // expect that the event stores the parameters
        #expect(event.key == key)
        #expect(event.error as? MockError == error)
    }
}
