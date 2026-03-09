//
//  ConfigVariableDetailViewModelTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/9/2026.
//

import Configuration
import DevTesting
import Foundation
import Testing

@testable import DevConfiguration

@MainActor
struct ConfigVariableDetailViewModelTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()

    let editorOverrideProvider: EditorOverrideProvider
    var workingCopyDisplayName: String!
    let undoManager = UndoManager()


    init() {
        let userDefaults = UserDefaults(suiteName: "devkit.DevConfiguration.test.\(UUID())")!
        userDefaults.removeObject(forKey: "editorOverrides")
        editorOverrideProvider = EditorOverrideProvider(userDefaults: userDefaults)
        workingCopyDisplayName = randomAlphanumericString()
    }


    // MARK: - Helpers

    mutating func makeDocument(
        namedProviders: [NamedConfigProvider] = [],
        registeredVariables: [RegisteredConfigVariable]
    ) -> EditorDocument {
        EditorDocument(
            editorOverrideProvider: editorOverrideProvider,
            workingCopyDisplayName: workingCopyDisplayName,
            namedProviders: namedProviders,
            registeredVariables: registeredVariables,
            undoManager: undoManager
        )
    }


    mutating func makeViewModel(
        document: EditorDocument,
        registeredVariable: RegisteredConfigVariable
    ) -> ConfigVariableDetailViewModel {
        ConfigVariableDetailViewModel(document: document, registeredVariable: registeredVariable)
    }


    // MARK: - init

    @Test
    mutating func initSetsConstantProperties() {
        // set up
        var metadata = ConfigVariableMetadata()
        metadata.displayName = randomAlphanumericString()
        let destinationTypeName = randomAlphanumericString()
        let isSecret = randomBool()

        let variable = randomRegisteredVariable(
            isSecret: isSecret,
            metadata: metadata,
            destinationTypeName: destinationTypeName,
            editorControl: .textField
        )

        let document = makeDocument(registeredVariables: [variable])

        // exercise
        let viewModel = makeViewModel(document: document, registeredVariable: variable)

        // expect all constant properties are set from the registered variable
        #expect(viewModel.key == variable.key)
        #expect(viewModel.displayName == metadata.displayName)
        #expect(viewModel.contentTypeName == variable.contentTypeName)
        #expect(viewModel.variableTypeName == variable.destinationTypeName)
        #expect(viewModel.metadataEntries == metadata.displayTextEntries)
        #expect(viewModel.isSecret == isSecret)
        #expect(viewModel.editorControl == .textField)
    }


    @Test
    mutating func initUsesKeyDescriptionWhenDisplayNameIsNil() {
        // set up with no display name metadata
        let variable = randomRegisteredVariable()
        let document = makeDocument(registeredVariables: [variable])

        // exercise
        let viewModel = makeViewModel(document: document, registeredVariable: variable)

        // expect the key's description is used
        #expect(viewModel.displayName == variable.key.description)
    }


    @Test
    mutating func initSetsOverrideTextFromExistingOverride() {
        // set up with an override in the document
        let defaultContent = ConfigContent.string(randomAlphanumericString())
        let variable = randomRegisteredVariable(defaultContent: defaultContent)
        let document = makeDocument(registeredVariables: [variable])

        let overrideContent = ConfigContent.string(randomAlphanumericString())
        document.setOverride(overrideContent, forKey: variable.key)

        // exercise
        let viewModel = makeViewModel(document: document, registeredVariable: variable)

        // expect override text comes from the override content
        #expect(viewModel.overrideText == overrideContent.displayString)
    }


    @Test
    mutating func initSetsOverrideTextFromResolvedValue() {
        // set up with no override but a resolved value from defaults
        let defaultContent = ConfigContent.int(randomInt(in: .min ... .max))
        let variable = randomRegisteredVariable(defaultContent: defaultContent)
        let document = makeDocument(registeredVariables: [variable])

        // exercise
        let viewModel = makeViewModel(document: document, registeredVariable: variable)

        // expect override text comes from the resolved default value
        #expect(viewModel.overrideText == defaultContent.displayString)
    }


    // MARK: - providerValues

    @Test
    mutating func providerValuesDelegatesToDocument() {
        // set up with a provider and a default
        let defaultContent = ConfigContent.string(randomAlphanumericString())
        let variable = randomRegisteredVariable(defaultContent: defaultContent)

        let providerContent = ConfigContent.string(randomAlphanumericString())
        let provider = InMemoryProvider(
            values: [
                AbsoluteConfigKey(variable.key): ConfigValue(providerContent, isSecret: false)
            ]
        )
        let providerDisplayName = randomAlphanumericString()

        let document = makeDocument(
            namedProviders: [.init(provider, displayName: providerDisplayName)],
            registeredVariables: [variable]
        )
        let viewModel = makeViewModel(document: document, registeredVariable: variable)

        // exercise
        let values = viewModel.providerValues

        // expect the values match what the document returns
        #expect(values == document.providerValues(forKey: variable.key))
    }


    // MARK: - isOverrideEnabled

    @Test
    mutating func isOverrideEnabledReturnsTrueWhenOverrideExists() {
        // set up with an override
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])
        document.setOverride(.string(randomAlphanumericString()), forKey: variable.key)

        let viewModel = makeViewModel(document: document, registeredVariable: variable)

        // exercise and expect
        #expect(viewModel.isOverrideEnabled)
    }


    @Test
    mutating func isOverrideEnabledReturnsFalseWhenNoOverride() {
        // set up with no override
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])

        let viewModel = makeViewModel(document: document, registeredVariable: variable)

        // exercise and expect
        #expect(!viewModel.isOverrideEnabled)
    }


    @Test
    mutating func settingIsOverrideEnabledToTrueSetsOverrideFromResolvedValue() {
        // set up with a provider value that will be the resolved value
        let defaultContent = ConfigContent.string(randomAlphanumericString())
        let variable = randomRegisteredVariable(defaultContent: defaultContent)

        let providerContent = ConfigContent.string(randomAlphanumericString())
        let provider = InMemoryProvider(
            values: [
                AbsoluteConfigKey(variable.key): ConfigValue(providerContent, isSecret: false)
            ]
        )

        let document = makeDocument(
            namedProviders: [.init(provider, displayName: randomAlphanumericString())],
            registeredVariables: [variable]
        )
        let viewModel = makeViewModel(document: document, registeredVariable: variable)

        // exercise
        viewModel.isOverrideEnabled = true

        // expect the override is set to the resolved value (provider content wins over default)
        #expect(document.override(forKey: variable.key) == providerContent)
    }


    @Test
    mutating func settingIsOverrideEnabledToTrueUsesDefaultContentWhenResolvedValueIsNil() {
        // set up with a variable that is not registered in the document, so resolvedValue returns nil
        let defaultContent = ConfigContent.string(randomAlphanumericString())
        let variable = randomRegisteredVariable(defaultContent: defaultContent)
        let otherVariable = randomRegisteredVariable()

        let document = makeDocument(registeredVariables: [otherVariable])
        let viewModel = makeViewModel(document: document, registeredVariable: variable)

        // exercise
        viewModel.isOverrideEnabled = true

        // expect the override is set to the registered variable's default content
        #expect(document.override(forKey: variable.key) == defaultContent)
        #expect(viewModel.overrideText == defaultContent.displayString)
    }


    @Test
    mutating func settingIsOverrideEnabledToTrueUpdatesOverrideText() {
        // set up
        let defaultContent = ConfigContent.string(randomAlphanumericString())
        let variable = randomRegisteredVariable(defaultContent: defaultContent)
        let document = makeDocument(registeredVariables: [variable])
        let viewModel = makeViewModel(document: document, registeredVariable: variable)

        // exercise
        viewModel.isOverrideEnabled = true

        // expect override text is updated to the resolved value's display string
        #expect(viewModel.overrideText == defaultContent.displayString)
    }


    @Test
    mutating func settingIsOverrideEnabledToFalseRemovesOverride() {
        // set up with an existing override
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])
        document.setOverride(.string(randomAlphanumericString()), forKey: variable.key)

        let viewModel = makeViewModel(document: document, registeredVariable: variable)

        // exercise
        viewModel.isOverrideEnabled = false

        // expect the override is removed
        #expect(!document.hasOverride(forKey: variable.key))
    }


    // MARK: - overrideBool

    @Test
    mutating func overrideBoolReturnsBoolValue() {
        // set up with a bool override
        let boolValue = randomBool()
        let variable = randomRegisteredVariable(defaultContent: .bool(boolValue))
        let document = makeDocument(registeredVariables: [variable])
        document.setOverride(.bool(boolValue), forKey: variable.key)

        let viewModel = makeViewModel(document: document, registeredVariable: variable)

        // exercise and expect
        #expect(viewModel.overrideBool == boolValue)
    }


    @Test
    mutating func overrideBoolReturnsFalseWhenNotBool() {
        // set up with a non-bool override
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])
        document.setOverride(.string(randomAlphanumericString()), forKey: variable.key)

        let viewModel = makeViewModel(document: document, registeredVariable: variable)

        // exercise and expect
        #expect(!viewModel.overrideBool)
    }


    @Test
    mutating func settingOverrideBoolSetsDocumentOverride() {
        // set up
        let variable = randomRegisteredVariable(defaultContent: .bool(false))
        let document = makeDocument(registeredVariables: [variable])
        let viewModel = makeViewModel(document: document, registeredVariable: variable)

        // exercise
        viewModel.overrideBool = true

        // expect the document has a bool override
        #expect(document.override(forKey: variable.key) == .bool(true))
    }


    // MARK: - commitOverrideText

    @Test
    mutating func commitOverrideTextParsesAndSetsOverride() {
        // set up with a parse function that parses strings to .string content
        let variable = randomRegisteredVariable(
            defaultContent: .string(randomAlphanumericString()),
            editorControl: .textField,
            parse: { .string($0) }
        )
        let document = makeDocument(registeredVariables: [variable])
        let viewModel = makeViewModel(document: document, registeredVariable: variable)

        let inputText = randomAlphanumericString()
        viewModel.overrideText = inputText

        // exercise
        viewModel.commitOverrideText()

        // expect the parsed content is set as an override
        #expect(document.override(forKey: variable.key) == .string(inputText))
    }


    @Test
    mutating func commitOverrideTextDoesNothingWhenParseIsNil() {
        // set up with no parse function
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])
        let viewModel = makeViewModel(document: document, registeredVariable: variable)

        viewModel.overrideText = randomAlphanumericString()

        // exercise
        viewModel.commitOverrideText()

        // expect no override is set
        #expect(!document.hasOverride(forKey: variable.key))
    }


    @Test
    mutating func commitOverrideTextDoesNothingWhenParseReturnsNil() {
        // set up with a parse function that always returns nil
        let variable = randomRegisteredVariable(
            defaultContent: .string(randomAlphanumericString()),
            editorControl: .textField,
            parse: { _ in nil }
        )
        let document = makeDocument(registeredVariables: [variable])
        let viewModel = makeViewModel(document: document, registeredVariable: variable)

        viewModel.overrideText = randomAlphanumericString()

        // exercise
        viewModel.commitOverrideText()

        // expect no override is set
        #expect(!document.hasOverride(forKey: variable.key))
    }
}
