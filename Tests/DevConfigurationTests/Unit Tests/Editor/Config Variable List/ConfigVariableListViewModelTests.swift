//
//  ConfigVariableListViewModelTests.swift
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
struct ConfigVariableListViewModelTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()

    let editorOverrideProvider = EditorOverrideProvider()
    var userDefaults: UserDefaults!
    var workingCopyDisplayName: String!
    let undoManager = UndoManager()

    nonisolated(unsafe) var onSaveStub: Stub<[RegisteredConfigVariable], Void>!


    init() {
        workingCopyDisplayName = randomAlphanumericString()
        userDefaults = UserDefaults(suiteName: randomAlphanumericString())!
        onSaveStub = Stub()
    }


    // MARK: - Helpers

    mutating func makeDocument(
        namedProviders: [NamedConfigProvider] = [],
        registeredVariables: [RegisteredConfigVariable]? = nil
    ) -> EditorDocument {
        EditorDocument(
            editorOverrideProvider: editorOverrideProvider,
            workingCopyDisplayName: workingCopyDisplayName,
            namedProviders: namedProviders,
            registeredVariables: registeredVariables ?? [randomRegisteredVariable()],
            userDefaults: userDefaults,
            undoManager: undoManager
        )
    }


    func makeViewModel(document: EditorDocument) -> ConfigVariableListViewModel {
        ConfigVariableListViewModel(document: document, onSave: { self.onSaveStub($0) })
    }


    // MARK: - variables

    @Test
    mutating func variablesMapsItemsFromDocument() {
        // set up with two registered variables that have display names
        var metadata1 = ConfigVariableMetadata()
        metadata1.displayName = "Alpha"
        let defaultContent1 = ConfigContent.string(randomAlphanumericString())
        let variable1 = randomRegisteredVariable(defaultContent: defaultContent1, metadata: metadata1)

        var metadata2 = ConfigVariableMetadata()
        metadata2.displayName = "Beta"
        let defaultContent2 = ConfigContent.int(randomInt(in: .min ... .max))
        let variable2 = randomRegisteredVariable(defaultContent: defaultContent2, metadata: metadata2)

        let document = makeDocument(registeredVariables: [variable1, variable2])
        let viewModel = makeViewModel(document: document)

        // exercise
        let items = viewModel.variables

        // expect items sorted by display name with correct fields
        let expected = [
            VariableListItem(
                key: variable1.key,
                displayName: "Alpha",
                currentValue: defaultContent1.displayString,
                providerName: localizedString("editor.defaultProviderName"),
                providerIndex: 0,
                isSecret: variable1.isSecret,
                hasOverride: false,
                editorControl: variable1.editorControl
            ),
            VariableListItem(
                key: variable2.key,
                displayName: "Beta",
                currentValue: defaultContent2.displayString,
                providerName: localizedString("editor.defaultProviderName"),
                providerIndex: 0,
                isSecret: variable2.isSecret,
                hasOverride: false,
                editorControl: variable2.editorControl
            ),
        ]
        #expect(items == expected)
    }


    @Test
    mutating func variablesUsesKeyDescriptionWhenDisplayNameIsNil() {
        // set up with a variable that has no display name metadata
        let defaultContent = ConfigContent.string(randomAlphanumericString())
        let variable = randomRegisteredVariable(defaultContent: defaultContent)

        let document = makeDocument(registeredVariables: [variable])
        let viewModel = makeViewModel(document: document)

        // exercise
        let items = viewModel.variables

        // expect the item uses the key's description as the display name
        let expected = [
            VariableListItem(
                key: variable.key,
                displayName: variable.key.description,
                currentValue: defaultContent.displayString,
                providerName: localizedString("editor.defaultProviderName"),
                providerIndex: 0,
                isSecret: variable.isSecret,
                hasOverride: false,
                editorControl: variable.editorControl
            )
        ]
        #expect(items == expected)
    }


    @Test
    mutating func variablesFiltersByDisplayName() {
        // set up with two variables, one matching the search text
        var metadata1 = ConfigVariableMetadata()
        metadata1.displayName = "ServerURL"
        let variable1 = randomRegisteredVariable(
            defaultContent: .string(randomAlphanumericString()),
            metadata: metadata1
        )

        var metadata2 = ConfigVariableMetadata()
        metadata2.displayName = "Timeout"
        let variable2 = randomRegisteredVariable(
            defaultContent: .int(randomInt(in: .min ... .max)),
            metadata: metadata2
        )

        let document = makeDocument(registeredVariables: [variable1, variable2])
        let viewModel = makeViewModel(document: document)
        viewModel.searchText = "Server"

        // exercise
        let items = viewModel.variables

        // expect only the matching variable is returned
        #expect(items.count == 1)
        #expect(items.first?.displayName == "ServerURL")
    }


    @Test
    mutating func variablesFiltersByKeyDescription() {
        // set up with a variable whose display name doesn't match but key does
        var metadata = ConfigVariableMetadata()
        metadata.displayName = "Something Else"
        let key = ConfigKey(["server", "url"])
        let variable = randomRegisteredVariable(
            key: key,
            defaultContent: .string(randomAlphanumericString()),
            metadata: metadata
        )

        let document = makeDocument(registeredVariables: [variable])
        let viewModel = makeViewModel(document: document)
        viewModel.searchText = "server"

        // exercise
        let items = viewModel.variables

        // expect the variable is returned because the key matches
        #expect(items.count == 1)
        #expect(items.first?.key == key)
    }


    @Test
    mutating func variablesReturnsAllWhenSearchTextIsEmpty() {
        // set up with two variables and empty search text
        let variable1 = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let variable2 = randomRegisteredVariable(defaultContent: .int(randomInt(in: .min ... .max)))

        let document = makeDocument(registeredVariables: [variable1, variable2])
        let viewModel = makeViewModel(document: document)

        // exercise
        let items = viewModel.variables

        // expect all variables are returned
        #expect(items.count == 2)
    }


    @Test
    mutating func variablesSortsByDisplayName() {
        // set up with variables whose display names sort in a specific order
        var metadataC = ConfigVariableMetadata()
        metadataC.displayName = "Charlie"
        let variableC = randomRegisteredVariable(
            defaultContent: .string(randomAlphanumericString()),
            metadata: metadataC
        )

        var metadataA = ConfigVariableMetadata()
        metadataA.displayName = "Alpha"
        let variableA = randomRegisteredVariable(
            defaultContent: .string(randomAlphanumericString()),
            metadata: metadataA
        )

        var metadataB = ConfigVariableMetadata()
        metadataB.displayName = "Bravo"
        let variableB = randomRegisteredVariable(
            defaultContent: .string(randomAlphanumericString()),
            metadata: metadataB
        )

        // register in non-sorted order
        let document = makeDocument(registeredVariables: [variableC, variableA, variableB])
        let viewModel = makeViewModel(document: document)

        // exercise
        let items = viewModel.variables

        // expect items are sorted by display name
        let displayNames = items.map(\.displayName)
        #expect(displayNames == ["Alpha", "Bravo", "Charlie"])
    }


    // MARK: - isDirty

    @Test
    mutating func isDirtyDelegatesToDocument() {
        // set up
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])
        let viewModel = makeViewModel(document: document)

        // expect clean initially
        #expect(!viewModel.isDirty)

        // exercise by adding an override
        document.setOverride(.string(randomAlphanumericString()), forKey: variable.key)

        // expect dirty
        #expect(viewModel.isDirty)
    }


    // MARK: - canUndo

    @Test
    mutating func canUndoDelegatesToUndoManager() {
        // set up
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])
        let viewModel = makeViewModel(document: document)

        // expect can't undo initially
        #expect(!viewModel.canUndo)

        // exercise by adding an override
        document.setOverride(.string(randomAlphanumericString()), forKey: variable.key)

        // expect can undo
        #expect(viewModel.canUndo)
    }


    // MARK: - canRedo

    @Test
    mutating func canRedoDelegatesToUndoManager() {
        // set up with an override then undo
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])
        let viewModel = makeViewModel(document: document)

        document.setOverride(.string(randomAlphanumericString()), forKey: variable.key)
        undoManager.undo()

        // exercise
        let canRedo = viewModel.canRedo

        // expect can redo after undo
        #expect(canRedo)
    }


    // MARK: - requestDismiss

    @Test
    mutating func requestDismissCallsDismissWhenClean() async {
        // set up with no overrides
        let document = makeDocument()
        let viewModel = makeViewModel(document: document)

        // exercise
        await confirmation { dismissed in
            viewModel.requestDismiss { dismissed() }
        }

        // expect save alert is not showing
        #expect(!viewModel.isShowingSaveAlert)
    }


    @Test
    mutating func requestDismissShowsSaveAlertWhenDirty() {
        // set up with an override to make the document dirty
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])
        let viewModel = makeViewModel(document: document)

        document.setOverride(.string(randomAlphanumericString()), forKey: variable.key)

        // exercise
        viewModel.requestDismiss {}

        // expect save alert is showing and dismiss was not called
        #expect(viewModel.isShowingSaveAlert)
    }


    // MARK: - save

    @Test
    mutating func saveCallsOnSaveWithChangedVariables() throws {
        // set up with an override
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])
        let viewModel = makeViewModel(document: document)

        document.setOverride(.string(randomAlphanumericString()), forKey: variable.key)

        // exercise
        viewModel.save()

        // expect onSave was called with the changed variable and document is no longer dirty
        let savedVariables = try #require(onSaveStub.callArguments.first)
        #expect(savedVariables.map(\.key) == [variable.key])
        #expect(!viewModel.isDirty)
    }


    // MARK: - requestClearAllOverrides

    @Test
    mutating func requestClearAllOverridesShowsClearAlert() {
        // set up
        let document = makeDocument()
        let viewModel = makeViewModel(document: document)

        // exercise
        viewModel.requestClearAllOverrides()

        // expect clear alert is showing
        #expect(viewModel.isShowingClearAlert)
    }


    // MARK: - confirmClearAllOverrides

    @Test
    mutating func confirmClearAllOverridesDelegatesToDocument() {
        // set up with an override
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])
        let viewModel = makeViewModel(document: document)

        document.setOverride(.string(randomAlphanumericString()), forKey: variable.key)

        // exercise
        viewModel.confirmClearAllOverrides()

        // expect working copy is empty
        #expect(document.workingCopy.isEmpty)
    }


    // MARK: - undo

    @Test
    mutating func undoDelegatesToUndoManager() {
        // set up with an override
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])
        let viewModel = makeViewModel(document: document)

        document.setOverride(.string(randomAlphanumericString()), forKey: variable.key)

        // exercise
        viewModel.undo()

        // expect override is removed
        #expect(!document.hasOverride(forKey: variable.key))
    }


    // MARK: - redo

    @Test
    mutating func redoDelegatesToUndoManager() {
        // set up with an override then undo
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])
        let viewModel = makeViewModel(document: document)

        let content = ConfigContent.string(randomAlphanumericString())
        document.setOverride(content, forKey: variable.key)
        undoManager.undo()

        // exercise
        viewModel.redo()

        // expect override is restored
        #expect(document.override(forKey: variable.key) == content)
    }


    // MARK: - makeDetailViewModel

    @Test
    mutating func makeDetailViewModelReturnsViewModelForKey() {
        // set up
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])
        let viewModel = makeViewModel(document: document)

        // exercise
        let detailViewModel = viewModel.makeDetailViewModel(for: variable.key)

        // expect the detail view model has the correct key
        #expect(detailViewModel.key == variable.key)
    }
}
