//
//  ConfigVariableDecodingFailedEventTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/5/2026.
//

import Configuration
import DevConfiguration
import DevTesting
import Testing

struct ConfigVariableDecodingFailedEventTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initStoresParameters() {
        // set up
        let key = AbsoluteConfigKey(randomConfigKey())
        let targetType: Any.Type = String.self
        let error = MockError(id: randomAlphanumericString())

        // exercise
        let event = ConfigVariableDecodingFailedEvent(key: key, targetType: targetType, error: error)

        // expect
        #expect(event.key == key)
        #expect(event.targetType is String.Type)
        #expect(event.error as? MockError == error)
    }
}
