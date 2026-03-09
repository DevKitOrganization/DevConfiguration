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
