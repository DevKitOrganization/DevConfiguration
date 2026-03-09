//
//  ConfigVariableReaderTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 2/16/26.
//

import Configuration
import DevFoundation
import DevTesting
import Foundation
import Testing

@testable import DevConfiguration

struct ConfigVariableReaderTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()

    /// A mutable provider for testing.
    let provider = MutableInMemoryProvider(initialValues: [:])

    /// The event bus for testing event posting.
    let eventBus = EventBus()

    /// The reader under test.
    lazy var reader: ConfigVariableReader = {
        ConfigVariableReader(namedProviders: [.init(provider)], eventBus: eventBus)
    }()


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

        let reader = ConfigVariableReader(namedProviders: [.init(InMemoryProvider(values: [:]))], eventBus: EventBus())
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


    // MARK: - Event Bus Integration

    @Test
    mutating func valuePostsAccessSucceededEventWhenFound() async throws {
        // set up
        let observer = ContextualBusEventObserver(context: ())
        eventBus.addObserver(observer)

        let key = randomConfigKey()
        let expectedValue = randomBool()
        let variable = ConfigVariable<Bool>(key: key, defaultValue: !expectedValue)
        provider.setValue(
            .init(.bool(expectedValue), isSecret: randomBool()),
            forKey: .init(variable.key)
        )

        let (eventStream, continuation) = AsyncStream<ConfigVariableAccessSucceededEvent>.makeStream()
        observer.addHandler(for: ConfigVariableAccessSucceededEvent.self) { (event, _) in
            continuation.yield(event)
        }

        // exercise
        _ = reader.value(for: variable)

        // expect
        let postedEvent = try #require(await eventStream.first { _ in true })
        #expect(postedEvent.key == AbsoluteConfigKey(variable.key))
        #expect(postedEvent.value.content == .bool(expectedValue))
    }
}
