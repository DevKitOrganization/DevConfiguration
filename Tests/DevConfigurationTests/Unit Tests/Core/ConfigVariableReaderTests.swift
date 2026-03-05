//
//  ConfigVariableReaderTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 2/16/26.
//

import Configuration
import DevFoundation
import DevTesting
import Testing

@testable import DevConfiguration

struct ConfigVariableReaderTests: RandomValueGenerating {
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

        let rawRepresentableStringVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: MockStringEnum.allCases.randomElement(using: &randomNumberGenerator)!,
            secrecy: secrecy
        )

        let rawRepresentableStringArrayVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: Array(count: randomInt(in: 0 ... 5)) {
                MockStringEnum.allCases.randomElement(using: &randomNumberGenerator)!
            },
            secrecy: secrecy
        )

        let expressibleByConfigStringVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: MockConfigStringValue(configString: randomAlphanumericString())!,
            secrecy: secrecy
        )

        let expressibleByConfigStringArrayVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: Array(count: randomInt(in: 0 ... 5)) {
                MockConfigStringValue(configString: randomAlphanumericString())!
            },
            secrecy: secrecy
        )

        let rawRepresentableIntVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: MockIntEnum.allCases.randomElement(using: &randomNumberGenerator)!,
            secrecy: secrecy
        )

        let rawRepresentableIntArrayVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: Array(count: randomInt(in: 0 ... 5)) {
                MockIntEnum.allCases.randomElement(using: &randomNumberGenerator)!
            },
            secrecy: secrecy
        )

        let expressibleByConfigIntVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: MockConfigIntValue(configInt: randomInt(in: .min ... .max))!,
            secrecy: secrecy
        )

        let expressibleByConfigIntArrayVariable = ConfigVariable(
            key: randomConfigKey(),
            defaultValue: Array(count: randomInt(in: 0 ... 5)) {
                MockConfigIntValue(configInt: randomInt(in: .min ... .max))!
            },
            secrecy: secrecy
        )

        let isNotPublic = [.secret, .auto].contains(secrecy)
        let isSecret = secrecy == .secret

        let reader = ConfigVariableReader(providers: [InMemoryProvider(values: [:])], eventBus: EventBus())
        #expect(reader.isSecret(intVariable) == isSecret)
        #expect(reader.isSecret(stringVariable) == isNotPublic)
        #expect(reader.isSecret(stringArrayVariable) == isNotPublic)
        #expect(reader.isSecret(rawRepresentableStringVariable) == isNotPublic)
        #expect(reader.isSecret(rawRepresentableStringArrayVariable) == isNotPublic)
        #expect(reader.isSecret(expressibleByConfigStringVariable) == isNotPublic)
        #expect(reader.isSecret(expressibleByConfigStringArrayVariable) == isNotPublic)
        #expect(reader.isSecret(rawRepresentableIntVariable) == isSecret)
        #expect(reader.isSecret(rawRepresentableIntArrayVariable) == isSecret)
        #expect(reader.isSecret(expressibleByConfigIntVariable) == isSecret)
        #expect(reader.isSecret(expressibleByConfigIntArrayVariable) == isSecret)
    }
}


// MARK: - MockStringEnum

private enum MockStringEnum: String, CaseIterable, Sendable {
    case alpha
    case bravo
    case charlie
}


// MARK: - MockConfigStringValue

private struct MockConfigStringValue: ExpressibleByConfigString, Hashable, Sendable {
    let stringValue: String
    var description: String { stringValue }


    init?(configString: String) {
        self.stringValue = configString
    }
}


// MARK: - MockIntEnum

private enum MockIntEnum: Int, CaseIterable, Sendable {
    case one = 1
    case two = 2
    case three = 3
    case four = 4
}


// MARK: - MockConfigIntValue

private struct MockConfigIntValue: ExpressibleByConfigInt, Hashable, Sendable {
    let intValue: Int
    var configInt: Int { intValue }
    var description: String { "\(intValue)" }


    init?(configInt: Int) {
        self.intValue = configInt
    }
}
