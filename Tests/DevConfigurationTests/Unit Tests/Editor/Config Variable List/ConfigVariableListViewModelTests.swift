//
//  ConfigVariableListViewModelTests.swift
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
struct ConfigVariableListViewModelTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    // MARK: - Variables

    @Test
    mutating func variablesSortedByDisplayName() {
        // set up
        let displayNames = Array(count: 3) { randomAlphanumericString() }
        let sortedNames = displayNames.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }

        var variables: [ConfigKey: RegisteredConfigVariable] = [:]
        for name in displayNames {
            let key = randomConfigKey()
            var metadata = ConfigVariableMetadata()
            metadata.displayName = name
            variables[key] = randomRegisteredVariable(key: key, metadata: metadata)
        }

        let viewModel = makeListViewModel(registeredVariables: variables)

        // exercise
        let resultNames = viewModel.variables.map(\.displayName)

        // expect
        #expect(resultNames == sortedNames)
    }


    @Test
    mutating func variableUsesKeyDescriptionWhenNoDisplayName() throws {
        // set up
        let key = randomConfigKey()
        let variables: [ConfigKey: RegisteredConfigVariable] = [
            key: randomRegisteredVariable(key: key)
        ]

        let viewModel = makeListViewModel(registeredVariables: variables)

        // exercise
        let item = try #require(viewModel.variables.first)

        // expect
        #expect(item.displayName == key.description)
    }


    @Test
    mutating func variableShowsOverrideValueWhenOverrideExists() throws {
        // set up
        let key = randomConfigKey()
        let overrideContent = ConfigContent.int(randomInt(in: -100 ... 100))
        let variables: [ConfigKey: RegisteredConfigVariable] = [
            key: randomRegisteredVariable(key: key, defaultContent: .int(0), editorControl: .numberField)
        ]

        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        document.setOverride(overrideContent, forKey: key)

        let viewModel = makeListViewModel(document: document, registeredVariables: variables, providers: [provider])

        // exercise
        let item = try #require(viewModel.variables.first)

        // expect
        #expect(item.currentValue == overrideContent.displayString)
        #expect(item.providerName == EditorOverrideProvider.providerName)
        #expect(item.hasOverride)
    }


    @Test
    mutating func variableShowsProviderValueWhenNoOverride() throws {
        // set up
        let key = randomConfigKey()
        let content = ConfigContent.string(randomAlphanumericString())
        let inMemoryProvider = InMemoryProvider(
            name: randomAlphanumericString(),
            values: [AbsoluteConfigKey(key): ConfigValue(content, isSecret: false)]
        )

        let variables: [ConfigKey: RegisteredConfigVariable] = [
            key: randomRegisteredVariable(key: key, defaultContent: .string(""), editorControl: .textField)
        ]

        let viewModel = makeListViewModel(registeredVariables: variables, providers: [inMemoryProvider])

        // exercise
        let item = try #require(viewModel.variables.first)

        // expect
        #expect(item.currentValue == content.displayString)
        #expect(item.providerName == inMemoryProvider.providerName)
        #expect(!item.hasOverride)
    }


    @Test
    mutating func variableShowsDefaultWhenNoProviderHasValue() throws {
        // set up
        let key = randomConfigKey()
        let defaultContent = ConfigContent.bool(randomBool())

        let variables: [ConfigKey: RegisteredConfigVariable] = [
            key: randomRegisteredVariable(key: key, defaultContent: defaultContent, editorControl: .toggle)
        ]

        let viewModel = makeListViewModel(registeredVariables: variables)

        // exercise
        let item = try #require(viewModel.variables.first)

        // expect
        #expect(item.currentValue == defaultContent.displayString)
        #expect(item.providerName != "editor.defaultProviderName")
    }


    // MARK: - Search

    @Test
    mutating func searchFiltersVariablesByDisplayName() {
        // set up
        let targetName = randomAlphanumericString()
        let otherName = randomAlphanumericString()

        let key1 = randomConfigKey()
        let key2 = randomConfigKey()

        var metadata1 = ConfigVariableMetadata()
        metadata1.displayName = targetName
        var metadata2 = ConfigVariableMetadata()
        metadata2.displayName = otherName

        let variables: [ConfigKey: RegisteredConfigVariable] = [
            key1: randomRegisteredVariable(key: key1, metadata: metadata1),
            key2: randomRegisteredVariable(key: key2, metadata: metadata2),
        ]

        let viewModel = makeListViewModel(registeredVariables: variables)

        // exercise
        viewModel.searchText = targetName

        // expect
        #expect(viewModel.variables.map(\.displayName) == [targetName])
    }


    @Test
    mutating func searchFiltersVariablesByCurrentValue() {
        // set up
        let key = randomConfigKey()
        let searchableValue = randomAlphanumericString()
        let content = ConfigContent.string(searchableValue)
        let inMemoryProvider = InMemoryProvider(
            values: [AbsoluteConfigKey(key): ConfigValue(content, isSecret: false)]
        )

        let variables: [ConfigKey: RegisteredConfigVariable] = [
            key: randomRegisteredVariable(key: key, defaultContent: .string(""), editorControl: .textField)
        ]

        let viewModel = makeListViewModel(registeredVariables: variables, providers: [inMemoryProvider])

        // exercise
        viewModel.searchText = searchableValue

        // expect
        #expect(viewModel.variables.count == 1)
    }


    @Test
    mutating func searchWithNoMatchReturnsEmpty() {
        // set up
        let key = randomConfigKey()
        var metadata = ConfigVariableMetadata()
        metadata.displayName = randomAlphanumericString()
        let variables: [ConfigKey: RegisteredConfigVariable] = [
            key: randomRegisteredVariable(key: key, metadata: metadata)
        ]

        let viewModel = makeListViewModel(registeredVariables: variables)

        // exercise
        viewModel.searchText = randomAlphanumericString()

        // expect
        #expect(viewModel.variables.isEmpty)
    }


    @Test
    mutating func emptySearchReturnsAllVariables() {
        // set up
        let key1 = randomConfigKey()
        let key2 = randomConfigKey()
        let variables: [ConfigKey: RegisteredConfigVariable] = [
            key1: randomRegisteredVariable(key: key1),
            key2: randomRegisteredVariable(key: key2),
        ]

        let viewModel = makeListViewModel(registeredVariables: variables)

        // exercise
        viewModel.searchText = ""

        // expect
        #expect(viewModel.variables.count == 2)
    }


    // MARK: - Dirty Tracking

    @Test
    mutating func isDirtyDelegatesToDocument() {
        // set up
        let key = randomConfigKey()
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        let viewModel = makeListViewModel(document: document)

        #expect(!viewModel.isDirty)

        // exercise
        document.setOverride(randomConfigContent(), forKey: key)

        // expect
        #expect(viewModel.isDirty)
    }


    // MARK: - Save

    @Test
    mutating func saveReturnsChangedRegisteredVariables() {
        // set up
        let key1 = randomConfigKey()
        let key2 = randomConfigKey()

        let variable1 = randomRegisteredVariable(key: key1)
        let variable2 = randomRegisteredVariable(key: key2)

        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        document.setOverride(randomConfigContent(), forKey: key1)

        let viewModel = makeListViewModel(
            document: document,
            registeredVariables: [key1: variable1, key2: variable2],
            providers: [provider]
        )

        // exercise
        let changed = viewModel.save()

        // expect
        #expect(changed.map(\.key) == [key1])
    }


    // MARK: - Clear All Overrides

    @Test
    mutating func clearAllOverridesDelegatesToDocument() {
        // set up
        let key = randomConfigKey()
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        document.setOverride(randomConfigContent(), forKey: key)

        let viewModel = makeListViewModel(document: document)

        // exercise
        viewModel.clearAllOverrides()

        // expect
        #expect(document.workingCopy.isEmpty)
    }


    // MARK: - Undo/Redo

    @Test
    mutating func undoDelegatesToUndoManager() {
        // set up
        let key = randomConfigKey()
        let undoManager = UndoManager()
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider, undoManager: undoManager)
        document.setOverride(randomConfigContent(), forKey: key)

        let viewModel = makeListViewModel(document: document, undoManager: undoManager)
        #expect(viewModel.canUndo)

        // exercise
        viewModel.undo()

        // expect
        #expect(!document.hasOverride(forKey: key))
    }


    @Test
    mutating func redoDelegatesToUndoManager() {
        // set up
        let key = randomConfigKey()
        let content = randomConfigContent()
        let undoManager = UndoManager()
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider, undoManager: undoManager)
        document.setOverride(content, forKey: key)
        undoManager.undo()

        let viewModel = makeListViewModel(document: document, undoManager: undoManager)
        #expect(viewModel.canRedo)

        // exercise
        viewModel.redo()

        // expect
        #expect(document.override(forKey: key) == content)
    }


    // MARK: - Detail View Model

    @Test
    mutating func makeDetailViewModelReturnsViewModel() {
        // set up
        let key = randomConfigKey()
        let variable = randomRegisteredVariable(key: key)

        let viewModel = makeListViewModel(registeredVariables: [key: variable])

        // exercise
        let detailVM = viewModel.makeDetailViewModel(for: key)

        // expect
        #expect(detailVM.key == key)
    }
}


// MARK: - Helpers

extension ConfigVariableListViewModelTests {
    private func makeListViewModel(
        document: EditorDocument? = nil,
        registeredVariables: [ConfigKey: RegisteredConfigVariable] = [:],
        providers: [any ConfigProvider] = [],
        undoManager: UndoManager = UndoManager()
    ) -> ConfigVariableListViewModel {
        let effectiveDocument = document ?? EditorDocument(provider: EditorOverrideProvider())
        return ConfigVariableListViewModel(
            document: effectiveDocument,
            registeredVariables: registeredVariables,
            namedProviders: providers.map { NamedConfigProvider($0) },
            undoManager: undoManager
        )
    }


    private mutating func randomRegisteredVariable(
        key: ConfigKey? = nil,
        defaultContent: ConfigContent = .bool(false),
        metadata: ConfigVariableMetadata = ConfigVariableMetadata(),
        editorControl: EditorControl = .toggle
    ) -> RegisteredConfigVariable {
        RegisteredConfigVariable(
            key: key ?? randomConfigKey(),
            defaultContent: defaultContent,
            isSecret: randomBool(),
            metadata: metadata,
            editorControl: editorControl,
            parse: nil
        )
    }
}

#endif
