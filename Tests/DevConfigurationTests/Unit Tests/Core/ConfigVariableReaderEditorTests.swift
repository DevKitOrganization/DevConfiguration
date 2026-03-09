//
//  ConfigVariableReaderEditorTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/7/2026.
//

import Configuration
import DevFoundation
import DevTesting
import Testing

@testable import DevConfiguration

struct ConfigVariableReaderEditorTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    func editorDisabledByDefault() {
        // set up
        let reader = ConfigVariableReader(
            namedProviders: [.init(InMemoryProvider(values: [:]))],
            eventBus: EventBus()
        )

        // expect
        #expect(reader.editorOverrideProvider == nil)
    }


    @Test
    func editorDisabledExplicitly() {
        // set up
        let reader = ConfigVariableReader(
            namedProviders: [.init(InMemoryProvider(values: [:]))],
            eventBus: EventBus(),
            isEditorEnabled: false
        )

        // expect
        #expect(reader.editorOverrideProvider == nil)
    }


    @Test
    func editorEnabledCreatesProvider() {
        // set up
        let reader = ConfigVariableReader(namedProviders: [], eventBus: EventBus(), isEditorEnabled: true)

        // expect
        #expect(reader.editorOverrideProvider != nil)
    }


    @Test
    func editorProviderIsFirstInProviders() {
        // set up
        let otherProvider = InMemoryProvider(values: [:])
        let reader = ConfigVariableReader(
            namedProviders: [.init(otherProvider)],
            eventBus: EventBus(),
            isEditorEnabled: true
        )

        // expect
        #expect(reader.namedProviders.count == 2)
        #expect(reader.namedProviders.first?.provider is EditorOverrideProvider)
    }


    @Test
    mutating func editorOverrideTakesPrecedence() {
        // set up
        let key = randomConfigKey()
        let initialValue = randomAlphanumericString()
        let overrideValue = randomAlphanumericString()

        let otherProvider = InMemoryProvider(
            values: [
                AbsoluteConfigKey(key): ConfigValue(.string(initialValue), isSecret: false)
            ]
        )
        let reader = ConfigVariableReader(
            namedProviders: [.init(otherProvider)],
            eventBus: EventBus(),
            isEditorEnabled: true
        )

        let variable = ConfigVariable(
            key: key,
            defaultValue: randomAlphanumericString(),
            secrecy: .public
        )

        // Verify the provider value is returned before any override
        #expect(reader.value(for: variable) == initialValue)

        // exercise — set an override
        reader.editorOverrideProvider!.setOverride(.string(overrideValue), forKey: key)

        // expect the override takes precedence
        #expect(reader.value(for: variable) == overrideValue)
    }


    @Test
    func convenienceInitPassesIsEditorEnabled() {
        // set up
        let reader = ConfigVariableReader(namedProviders: [], eventBus: EventBus(), isEditorEnabled: true)

        // expect
        #expect(reader.editorOverrideProvider != nil)
    }
}
