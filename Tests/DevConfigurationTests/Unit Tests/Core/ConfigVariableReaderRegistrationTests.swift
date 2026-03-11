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
        let isSecret = randomBool()
        let variable = ConfigVariable(key: key, defaultValue: defaultValue, isSecret: isSecret)
            .metadata(\.testTeam, metadata[TestTeamMetadataKey.self])

        // exercise
        reader.register(variable)

        // expect
        let registered = try #require(reader.registeredVariables[key])
        #expect(registered.key == key)
        #expect(registered.defaultContent == .int(defaultValue))
        #expect(registered.isSecret == isSecret)
        #expect(registered.testTeam == metadata[TestTeamMetadataKey.self])
        #expect(registered.destinationTypeName == "Int")
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


    @Test
    mutating func registerExpressibleByConfigStringVariableUsesCorrectContent() throws {
        // set up
        let reader = ConfigVariableReader(namedProviders: [.init(InMemoryProvider(values: [:]))], eventBus: EventBus())
        let key = randomConfigKey()
        let variable = ConfigVariable(key: key, defaultValue: MockConfigStringValue(configString: "test")!)

        // exercise
        reader.register(variable)

        // expect
        let registered = try #require(reader.registeredVariables[key])
        #expect(registered.defaultContent == .string("test"))
        #expect(registered.editorControl == .textField)
        #expect(registered.validate != nil)
    }


    @Test
    mutating func registerExpressibleByConfigIntVariableUsesCorrectContent() throws {
        // set up
        let reader = ConfigVariableReader(namedProviders: [.init(InMemoryProvider(values: [:]))], eventBus: EventBus())
        let key = randomConfigKey()
        let variable = ConfigVariable(key: key, defaultValue: MockConfigIntValue(configInt: 42)!)

        // exercise
        reader.register(variable)

        // expect
        let registered = try #require(reader.registeredVariables[key])
        #expect(registered.defaultContent == .int(42))
        #expect(registered.editorControl == .numberField)
        #expect(registered.validate != nil)
    }


    @Test
    mutating func registerCaseIterableStringVariableUsesPickerControl() throws {
        // set up
        let reader = ConfigVariableReader(namedProviders: [.init(InMemoryProvider(values: [:]))], eventBus: EventBus())
        let key = randomConfigKey()
        let variable = ConfigVariable(key: key, defaultValue: MockStringEnum.alpha)

        // exercise
        reader.register(variable)

        // expect
        let registered = try #require(reader.registeredVariables[key])
        #expect(registered.defaultContent == .string("alpha"))
        #expect(registered.editorControl?.pickerOptions != nil)
        #expect(registered.parse == nil)
        #expect(registered.validate == nil)
    }


    @Test
    mutating func registerCaseIterableIntVariableUsesPickerControl() throws {
        // set up
        let reader = ConfigVariableReader(namedProviders: [.init(InMemoryProvider(values: [:]))], eventBus: EventBus())
        let key = randomConfigKey()
        let variable = ConfigVariable(key: key, defaultValue: MockIntEnum.one)

        // exercise
        reader.register(variable)

        // expect
        let registered = try #require(reader.registeredVariables[key])
        #expect(registered.defaultContent == .int(1))
        #expect(registered.editorControl?.pickerOptions != nil)
        #expect(registered.parse == nil)
        #expect(registered.validate == nil)
    }


    @Test
    mutating func registerCapturesValidateForRawRepresentableStringVariable() throws {
        // set up
        let reader = ConfigVariableReader(namedProviders: [.init(InMemoryProvider(values: [:]))], eventBus: EventBus())
        let key = randomConfigKey()
        let variable = ConfigVariable(key: key, defaultValue: MockNonIterableStringEnum.a)

        // exercise
        reader.register(variable)

        // expect validate is non-nil and works correctly
        let registered = try #require(reader.registeredVariables[key])
        let validate = try #require(registered.validate)
        #expect(validate(.string("a")))
        #expect(!validate(.string("invalid")))
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
                    parse: nil,
                    validate: nil
                )
            )

            reader.register(variable)
        }
    }
    #endif
}
