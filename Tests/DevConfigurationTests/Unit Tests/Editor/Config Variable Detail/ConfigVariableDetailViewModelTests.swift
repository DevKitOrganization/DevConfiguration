//
//  ConfigVariableDetailViewModelTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/8/2026.
//

#if canImport(SwiftUI)

import Configuration
import DevTesting
import Foundation
import Testing

@testable import DevConfiguration

@MainActor
struct ConfigVariableDetailViewModelTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    // MARK: - Properties

    @Test
    mutating func keyReturnsVariableKey() {
        // set up
        let key = randomConfigKey()
        let viewModel = makeDetailViewModel(key: key)

        // expect
        #expect(viewModel.key == key)
    }


    @Test
    mutating func displayNameReturnsMetadataDisplayName() {
        // set up
        let displayName = randomAlphanumericString()
        var metadata = ConfigVariableMetadata()
        metadata.displayName = displayName

        let viewModel = makeDetailViewModel(metadata: metadata)

        // expect
        #expect(viewModel.displayName == displayName)
    }


    @Test
    mutating func displayNameFallsBackToKeyDescription() {
        // set up
        let key = randomConfigKey()
        let viewModel = makeDetailViewModel(key: key)

        // expect
        #expect(viewModel.displayName == key.description)
    }


    @Test
    mutating func metadataEntriesReturnsVariableMetadata() {
        // set up
        let displayName = randomAlphanumericString()
        var metadata = ConfigVariableMetadata()
        metadata.displayName = displayName

        let viewModel = makeDetailViewModel(metadata: metadata)

        // expect
        #expect(viewModel.metadataEntries == metadata.displayTextEntries)
    }


    @Test
    mutating func editorControlReturnsVariableEditorControl() {
        // set up
        let editorControl = randomElement(in: [EditorControl.toggle, .textField, .numberField, .decimalField, .none])!
        let viewModel = makeDetailViewModel(editorControl: editorControl)

        // expect
        #expect(viewModel.editorControl == editorControl)
    }


    @Test(arguments: [false, true])
    mutating func isSecretReturnsVariableIsSecret(isSecret: Bool) {
        // set up
        let viewModel = makeDetailViewModel(isSecret: isSecret)

        // expect
        #expect(viewModel.isSecret == isSecret)
    }


    // MARK: - Provider Values

    @Test
    mutating func providerValuesQueriesProviders() throws {
        // set up
        let key = randomConfigKey()
        let content = ConfigContent.string(randomAlphanumericString())
        let providerName = randomAlphanumericString()
        let inMemoryProvider = InMemoryProvider(
            name: providerName,
            values: [AbsoluteConfigKey(key): ConfigValue(content, isSecret: false)]
        )

        let viewModel = makeDetailViewModel(
            key: key, defaultContent: .string(""), editorControl: .textField, providers: [inMemoryProvider]
        )

        // exercise
        let value = try #require(viewModel.providerValues.first)

        // expect
        #expect(value.providerName == inMemoryProvider.providerName)
        #expect(value.valueString == content.displayString)
    }


    @Test
    mutating func providerValuesExcludesProvidersWithNoValue() {
        // set up
        let key = randomConfigKey()
        let providerWithValue = InMemoryProvider(
            name: randomAlphanumericString(),
            values: [AbsoluteConfigKey(key): ConfigValue(.int(randomInt(in: -100 ... 100)), isSecret: false)]
        )
        let providerWithoutValue = InMemoryProvider(name: randomAlphanumericString(), values: [:])

        let viewModel = makeDetailViewModel(
            key: key,
            defaultContent: .int(0),
            editorControl: .numberField,
            providers: [providerWithValue, providerWithoutValue]
        )

        // expect
        #expect(viewModel.providerValues.map(\.providerName) == [providerWithValue.providerName])
    }


    // MARK: - Override Enable/Disable

    @Test
    mutating func isOverrideEnabledReturnsFalseWhenNoOverride() {
        // set up
        let viewModel = makeDetailViewModel()

        // expect
        #expect(!viewModel.isOverrideEnabled)
    }


    @Test
    mutating func settingIsOverrideEnabledToTrueSetsDefaultContent() {
        // set up
        let key = randomConfigKey()
        let defaultContent = ConfigContent.int(randomInt(in: -100 ... 100))
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)

        let viewModel = makeDetailViewModel(key: key, defaultContent: defaultContent, document: document)

        // exercise
        viewModel.isOverrideEnabled = true

        // expect
        #expect(viewModel.isOverrideEnabled)
        #expect(document.override(forKey: key) == defaultContent)
    }


    @Test
    mutating func settingIsOverrideEnabledToFalseRemovesOverride() {
        // set up
        let key = randomConfigKey()
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        document.setOverride(randomConfigContent(), forKey: key)

        let viewModel = makeDetailViewModel(key: key, document: document)

        // exercise
        viewModel.isOverrideEnabled = false

        // expect
        #expect(!viewModel.isOverrideEnabled)
        #expect(!document.hasOverride(forKey: key))
    }


    // MARK: - Override Text

    @Test
    mutating func overrideTextReturnsEmptyStringWhenNoOverride() {
        // set up
        let viewModel = makeDetailViewModel()

        // expect
        #expect(viewModel.overrideText == "")
    }


    @Test
    mutating func overrideTextReturnsDisplayStringOfOverride() {
        // set up
        let key = randomConfigKey()
        let value = randomAlphanumericString()
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        document.setOverride(.string(value), forKey: key)

        let viewModel = makeDetailViewModel(key: key, document: document)

        // expect
        #expect(viewModel.overrideText == value)
    }


    @Test
    mutating func settingOverrideTextParsesAndUpdatesDocument() {
        // set up
        let key = randomConfigKey()
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        document.setOverride(.int(0), forKey: key)

        let inputValue = randomInt(in: 1 ... 100)
        let viewModel = makeDetailViewModel(
            key: key,
            defaultContent: .int(0),
            editorControl: .numberField,
            parse: { Int($0).map { .int($0) } },
            document: document
        )

        // exercise
        viewModel.overrideText = String(inputValue)

        // expect
        #expect(document.override(forKey: key) == .int(inputValue))
    }


    @Test
    mutating func settingOverrideTextWithInvalidInputDoesNotUpdate() {
        // set up
        let key = randomConfigKey()
        let originalContent = ConfigContent.int(randomInt(in: -100 ... 100))
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        document.setOverride(originalContent, forKey: key)

        let viewModel = makeDetailViewModel(
            key: key,
            defaultContent: .int(0),
            editorControl: .numberField,
            parse: { Int($0).map { .int($0) } },
            document: document
        )

        // exercise
        viewModel.overrideText = randomAlphanumericString()

        // expect
        #expect(document.override(forKey: key) == originalContent)
    }


    // MARK: - Override Bool

    @Test
    mutating func overrideBoolReturnsFalseWhenNoOverride() {
        // set up
        let viewModel = makeDetailViewModel()

        // expect
        #expect(!viewModel.overrideBool)
    }


    @Test
    mutating func overrideBoolReturnsValueFromDocument() {
        // set up
        let key = randomConfigKey()
        let value = randomBool()
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        document.setOverride(.bool(value), forKey: key)

        let viewModel = makeDetailViewModel(key: key, document: document)

        // expect
        #expect(viewModel.overrideBool == value)
    }


    @Test
    mutating func settingOverrideBoolUpdatesDocument() {
        // set up
        let key = randomConfigKey()
        let value = randomBool()
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        document.setOverride(.bool(!value), forKey: key)

        let viewModel = makeDetailViewModel(key: key, document: document)

        // exercise
        viewModel.overrideBool = value

        // expect
        #expect(document.override(forKey: key) == .bool(value))
    }


    // MARK: - Secret Reveal

    @Test
    mutating func isSecretRevealedDefaultsToFalse() {
        // set up
        let viewModel = makeDetailViewModel()

        // expect
        #expect(!viewModel.isSecretRevealed)
    }


    @Test
    mutating func isSecretRevealedCanBeToggled() {
        // set up
        let viewModel = makeDetailViewModel()

        // exercise
        viewModel.isSecretRevealed = true

        // expect
        #expect(viewModel.isSecretRevealed)
    }
}


// MARK: - Helpers

extension ConfigVariableDetailViewModelTests {
    private mutating func makeDetailViewModel(
        key: ConfigKey? = nil,
        defaultContent: ConfigContent = .bool(false),
        isSecret: Bool? = nil,
        metadata: ConfigVariableMetadata = ConfigVariableMetadata(),
        editorControl: EditorControl = .toggle,
        parse: (@Sendable (String) -> ConfigContent?)? = nil,
        document: EditorDocument? = nil,
        providers: [any ConfigProvider] = []
    ) -> ConfigVariableDetailViewModel {
        let effectiveKey = key ?? randomConfigKey()
        let variable = RegisteredConfigVariable(
            key: effectiveKey,
            defaultContent: defaultContent,
            isSecret: isSecret ?? randomBool(),
            metadata: metadata,
            editorControl: editorControl,
            parse: parse
        )

        let effectiveDocument = document ?? EditorDocument(provider: EditorOverrideProvider())

        return ConfigVariableDetailViewModel(
            variable: variable,
            document: effectiveDocument,
            namedProviders: providers.map { NamedConfigProvider($0) }
        )
    }
}

#endif
