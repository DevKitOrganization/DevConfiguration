//
//  ConfigVariableReaderRegistrationTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/5/2026.
//

import Configuration
import DevFoundation
import DevTesting
import Foundation
import Testing

@testable import DevConfiguration

struct ConfigVariableReaderRegistrationTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func registerStoresVariableWithCorrectProperties() throws {
        // set up
        let reader = ConfigVariableReader(namedProviders: [.init(InMemoryProvider(values: [:]))], eventBus: EventBus())

        var metadata = ConfigVariableMetadata()
        metadata[TestTeamMetadataKey.self] = randomAlphanumericString()

        let key = randomConfigKey()
        let defaultValue = randomInt(in: .min ... .max)
        let secrecy = randomConfigVariableSecrecy()
        let variable = ConfigVariable(key: key, defaultValue: defaultValue, secrecy: secrecy)
            .metadata(\.testTeam, metadata[TestTeamMetadataKey.self])

        // exercise
        reader.register(variable)

        // expect
        let registered = try #require(reader.registeredVariables[key])
        #expect(registered.key == key)
        #expect(registered.defaultContent == .int(defaultValue))
        #expect(registered.isSecret == reader.isSecret(variable))
        #expect(registered.testTeam == metadata[TestTeamMetadataKey.self])
        #expect(registered.editorControl == .numberField)
        #expect(registered.parse?("42") == .int(42))
        #expect(registered.parse?("notAnInt") == nil)
    }


    @Test
    mutating func registerMultipleVariablesStoresAll() {
        // set up
        let reader = ConfigVariableReader(namedProviders: [.init(InMemoryProvider(values: [:]))], eventBus: EventBus())
        let key1 = randomConfigKey()
        let key2 = randomConfigKey()
        let variable1 = ConfigVariable(key: key1, defaultValue: randomBool())
        let variable2 = ConfigVariable(key: key2, defaultValue: randomAlphanumericString())

        // exercise
        reader.register(variable1)
        reader.register(variable2)

        // expect
        #expect(reader.registeredVariables.count == 2)
        #expect(reader.registeredVariables[key1] != nil)
        #expect(reader.registeredVariables[key2] != nil)
    }


    #if os(macOS)
    @Test
    func registerDuplicateKeyHalts() async {
        await #expect(processExitsWith: .failure) {
            let reader = ConfigVariableReader(
                namedProviders: [.init(InMemoryProvider(values: [:]))],
                eventBus: EventBus()
            )
            let variable1 = ConfigVariable(key: "duplicate.key", defaultValue: 1)
            let variable2 = ConfigVariable(key: "duplicate.key", defaultValue: 2)

            reader.register(variable1)
            reader.register(variable2)
        }
    }


    @Test
    func registerWithEncodeFailureHalts() async {
        await #expect(processExitsWith: .failure) {
            let reader = ConfigVariableReader(
                namedProviders: [.init(InMemoryProvider(values: [:]))],
                eventBus: EventBus()
            )
            let variable = ConfigVariable(
                key: "encode.failure",
                defaultValue: UnencodableValue(),
                content: ConfigVariableContent<UnencodableValue>(
                    isAutoSecret: false,
                    read: { _, _, _, defaultValue, _, _, _ in defaultValue },
                    fetch: { _, _, _, defaultValue, _, _, _ in defaultValue },
                    startWatching: { _, _, _, _, _, _, _, _ in },
                    encode: { _ in
                        throw EncodingError.invalidValue(
                            "",
                            .init(codingPath: [], debugDescription: "")
                        )
                    },
                    editorControl: .none,
                    parse: nil
                )
            )

            reader.register(variable)
        }
    }
    #endif
}
