//
//  EventBusAccessReporterTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 2/16/2026.
//

import Configuration
import DevFoundation
import DevTesting
import Foundation
import Testing

@testable import DevConfiguration

struct EventBusAccessReporterTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    // MARK: - init

    @Test
    func initStoresParameters() {
        // set up the test by creating an event bus
        let eventBus = EventBus()

        // exercise the test by creating the reporter
        let reporter = EventBusAccessReporter(eventBus: eventBus)

        // expect that the reporter stores the event bus
        #expect(reporter.eventBus === eventBus)
    }


    // MARK: - report(_:)

    @Test
    mutating func reportPostsAccessSucceededEventOnSuccess() async throws {
        // set up the test with an event bus and observer
        let eventBus = EventBus()
        let observer = ContextualBusEventObserver(context: ())
        eventBus.addObserver(observer)

        let reporter = EventBusAccessReporter(eventBus: eventBus)

        // set up an access event with a successful result and multiple provider results
        let key = randomAbsoluteConfigKey()
        let configValue = randomConfigValue()
        let providerResults = Array(count: randomInt(in: 2 ... 5)) {
            randomProviderResult()
        }

        let firstProviderName = providerResults.first!.providerName
        let accessEvent = randomAccessEvent(
            key: key,
            result: .success(configValue),
            providerResults: providerResults
        )

        // set up a stream to receive the posted event
        let (eventStream, continuation) = AsyncStream<ConfigVariableAccessSucceededEvent>.makeStream()
        observer.addHandler(for: ConfigVariableAccessSucceededEvent.self) { (event, _) in
            continuation.yield(event)
        }

        // exercise the test by reporting the access event
        reporter.report(accessEvent)

        // expect that a ConfigVariableAccessSucceededEvent was posted with correct values
        let postedEvent = try #require(await eventStream.first { _ in true })
        #expect(postedEvent.key == key)
        #expect(postedEvent.value == configValue)
        #expect(postedEvent.providerName == firstProviderName)
    }


    @Test
    mutating func reportPostsAccessFailedEventWithMissingValueErrorOnSuccessNil() async throws {
        // set up the test with an event bus and observer
        let eventBus = EventBus()
        let observer = ContextualBusEventObserver(context: ())
        eventBus.addObserver(observer)

        let reporter = EventBusAccessReporter(eventBus: eventBus)

        // set up an access event with a success(nil) result
        let key = randomAbsoluteConfigKey()
        let accessEvent = randomAccessEvent(
            key: key,
            result: .success(nil)
        )

        // set up a stream to receive the posted event
        let (eventStream, continuation) = AsyncStream<ConfigVariableAccessFailedEvent>.makeStream()
        observer.addHandler(for: ConfigVariableAccessFailedEvent.self) { (event, _) in
            continuation.yield(event)
        }

        // exercise the test by reporting the access event
        reporter.report(accessEvent)

        // expect that a ConfigVariableAccessFailedEvent was posted with MissingValueError
        let postedEvent = try #require(await eventStream.first { _ in true })
        #expect(postedEvent.key == key)
        #expect(postedEvent.error is MissingValueError)
    }


    @Test
    mutating func reportPostsAccessFailedEventOnFailure() async throws {
        // set up the test with an event bus and observer
        let eventBus = EventBus()
        let observer = ContextualBusEventObserver(context: ())
        eventBus.addObserver(observer)

        let reporter = EventBusAccessReporter(eventBus: eventBus)

        // set up an access event with a failure result
        let key = randomAbsoluteConfigKey()
        let error = randomError()
        let accessEvent = randomAccessEvent(
            key: key,
            result: .failure(error)
        )

        // set up a stream to receive the posted event
        let (eventStream, continuation) = AsyncStream<ConfigVariableAccessFailedEvent>.makeStream()
        observer.addHandler(for: ConfigVariableAccessFailedEvent.self) { (event, _) in
            continuation.yield(event)
        }

        // exercise the test by reporting the access event
        reporter.report(accessEvent)

        // expect that a ConfigVariableAccessFailedEvent was posted with the error
        let postedEvent = try #require(await eventStream.first { _ in true })
        #expect(postedEvent.key == key)
        #expect(postedEvent.error as? MockError == error)
    }
}
