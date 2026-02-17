//
//  ConfigVariable+SecrecyTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 2/16/26.
//

import Configuration
import DevTesting
import Testing

@testable import DevConfiguration

struct ConfigVariable_SecrecyTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    // MARK: - isSecret

    @Test(arguments: ConfigVariableSecrecy.allCases)
    mutating func isSecret(secrecy: ConfigVariableSecrecy) {
        let intVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: randomInt(in: .min ... .max),
            secrecy: secrecy
        )

        let stringVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: randomAlphanumericString(),
            secrecy: secrecy
        )

        let stringArrayVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: Array(count: randomInt(in: 0 ... 5)) { randomAlphanumericString() },
            secrecy: secrecy
        )

        #expect(intVariable.isSecret == (secrecy == .secret))
        #expect(stringVariable.isSecret == [.secret, .auto].contains(secrecy))
        #expect(stringArrayVariable.isSecret == [.secret, .auto].contains(secrecy))
    }
}
