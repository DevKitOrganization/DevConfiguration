//
//  EditorDocumentTests.swift
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
struct EditorDocumentTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()

    let editorOverrideProvider = EditorOverrideProvider()
    var userDefaults: UserDefaults!
    var workingCopyDisplayName: String!
    let undoManager = UndoManager()


    init() {
        workingCopyDisplayName = randomAlphanumericString()
        userDefaults = UserDefaults(suiteName: randomAlphanumericString())!
    }


    // MARK: - Helpers

    mutating func makeDocument(
        editorOverrideProvider: EditorOverrideProvider? = nil,
        namedProviders: [NamedConfigProvider] = [],
        registeredVariables: [RegisteredConfigVariable]? = nil
    ) -> EditorDocument {
        EditorDocument(
            editorOverrideProvider: editorOverrideProvider ?? self.editorOverrideProvider,
            workingCopyDisplayName: workingCopyDisplayName,
            namedProviders: namedProviders,
            registeredVariables: registeredVariables ?? [randomRegisteredVariable()],
            userDefaults: userDefaults,
            undoManager: undoManager
        )
    }


    // MARK: - Initialization

    @Test
    mutating func initStoresRegisteredVariablesByKey() throws {
        // set up with multiple registered variables
        let variable1 = randomRegisteredVariable()
        let variable2 = randomRegisteredVariable()

        // exercise
        let document = makeDocument(registeredVariables: [variable1, variable2])

        // expect each variable is stored keyed by its config key
        #expect(document.registeredVariables.count == 2)

        let registered1 = try #require(document.registeredVariables[variable1.key])
        #expect(registered1.key == variable1.key)
        #expect(registered1.defaultContent == variable1.defaultContent)

        let registered2 = try #require(document.registeredVariables[variable2.key])
        #expect(registered2.key == variable2.key)
        #expect(registered2.defaultContent == variable2.defaultContent)
    }


    @Test
    mutating func initSnapshotsProviders() throws {
        // set up with a registered variable and an InMemoryProvider that has a value for it
        let defaultContent = ConfigContent.string(randomAlphanumericString())
        let variable = randomRegisteredVariable(defaultContent: defaultContent)

        let providerContent = ConfigContent.string(randomAlphanumericString())
        let provider = InMemoryProvider(
            values: [
                AbsoluteConfigKey(variable.key): ConfigValue(providerContent, isSecret: false)
            ]
        )
        let displayName = randomAlphanumericString()

        // exercise
        let document = makeDocument(
            namedProviders: [.init(provider, displayName: displayName)],
            registeredVariables: [variable]
        )

        // expect first snapshot has correct display name, index, and value
        let snapshot = try #require(document.providerSnapshots.first)
        #expect(snapshot.displayName == displayName)
        #expect(snapshot.index == 0)
        #expect(snapshot.values[variable.key] == providerContent)
    }


    @Test
    mutating func initAppendsDefaultSnapshot() throws {
        // set up with a registered variable and one named provider
        let defaultContent = ConfigContent.int(randomInt(in: .min ... .max))
        let variable = randomRegisteredVariable(defaultContent: defaultContent)

        let provider = InMemoryProvider(values: [:])

        // exercise
        let document = makeDocument(
            namedProviders: [.init(provider, displayName: randomAlphanumericString())],
            registeredVariables: [variable]
        )

        // expect last snapshot is "Default" with index = namedProviders.count and default values
        let defaultSnapshot = try #require(document.providerSnapshots.last)
        #expect(defaultSnapshot.displayName == localizedString("editor.defaultProviderName"))
        #expect(defaultSnapshot.index == 1)
        #expect(defaultSnapshot.values[variable.key] == defaultContent)
    }


    @Test
    mutating func initCopiesExistingOverridesToWorkingCopy() {
        // set up by pre-populating the editor override provider
        let key = randomConfigKey()
        let content = ConfigContent.string(randomAlphanumericString())
        editorOverrideProvider.setOverride(content, forKey: key)

        let variable = randomRegisteredVariable(key: key, defaultContent: .string(randomAlphanumericString()))

        // exercise
        let document = makeDocument(registeredVariables: [variable])

        // expect working copy contains the pre-existing override
        #expect(document.workingCopy[key] == content)
    }


    // MARK: - Value Resolution

    @Test
    mutating func resolvedValuePrefersWorkingCopyOverProviders() throws {
        // set up with a provider value and a working copy override for the same key
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

        let overrideContent = ConfigContent.string(randomAlphanumericString())
        document.setOverride(overrideContent, forKey: variable.key)

        // exercise
        let resolved = try #require(document.resolvedValue(forKey: variable.key))

        // expect working copy wins
        #expect(resolved.content == overrideContent)
        #expect(resolved.providerDisplayName == workingCopyDisplayName)
        #expect(resolved.providerIndex == nil)
    }


    @Test
    mutating func resolvedValueSkipsMismatchedTypes() throws {
        // set up with a string variable but an int override in working copy
        let defaultContent = ConfigContent.string(randomAlphanumericString())
        let variable = randomRegisteredVariable(defaultContent: defaultContent)

        let providerContent = ConfigContent.string(randomAlphanumericString())
        let providerDisplayName = randomAlphanumericString()
        let provider = InMemoryProvider(
            values: [
                AbsoluteConfigKey(variable.key): ConfigValue(providerContent, isSecret: false)
            ]
        )

        let document = makeDocument(
            namedProviders: [.init(provider, displayName: providerDisplayName)],
            registeredVariables: [variable]
        )

        // set a mismatched type in the working copy
        document.setOverride(.int(randomInt(in: .min ... .max)), forKey: variable.key)

        // exercise
        let resolved = try #require(document.resolvedValue(forKey: variable.key))

        // expect the provider value wins since working copy type doesn't match
        #expect(resolved.content == providerContent)
        #expect(resolved.providerDisplayName == providerDisplayName)
        #expect(resolved.providerIndex == 0)
    }


    @Test
    mutating func resolvedValueFallsThroughToDefault() throws {
        // set up with no provider values and no working copy override
        let defaultContent = ConfigContent.bool(randomBool())
        let variable = randomRegisteredVariable(defaultContent: defaultContent)

        let document = makeDocument(registeredVariables: [variable])

        // exercise
        let resolved = try #require(document.resolvedValue(forKey: variable.key))

        // expect the default snapshot value wins
        #expect(resolved.content == defaultContent)
        #expect(resolved.providerDisplayName == localizedString("editor.defaultProviderName"))
        #expect(resolved.providerIndex == 0)
    }


    @Test
    mutating func resolvedValueReturnsNilForUnregisteredKey() {
        // set up with a document that has no variable for the queried key
        let document = makeDocument()

        // exercise
        let resolved = document.resolvedValue(forKey: randomConfigKey())

        // expect nil for an unregistered key
        #expect(resolved == nil)
    }


    // MARK: - Provider Values

    @Test
    mutating func providerValuesIncludesAllProvidersWithValues() {
        // set up with a working copy override, a provider value, and a default value
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

        let overrideContent = ConfigContent.string(randomAlphanumericString())
        document.setOverride(overrideContent, forKey: variable.key)

        // exercise
        let values = document.providerValues(forKey: variable.key)

        // expect three entries: working copy, provider, and default
        let expected = [
            ProviderValue(
                providerName: workingCopyDisplayName,
                providerIndex: nil,
                isActive: true,
                valueString: overrideContent.displayString,
                contentTypeMatches: true
            ),
            ProviderValue(
                providerName: providerDisplayName,
                providerIndex: 0,
                isActive: false,
                valueString: providerContent.displayString,
                contentTypeMatches: true
            ),
            ProviderValue(
                providerName: localizedString("editor.defaultProviderName"),
                providerIndex: 1,
                isActive: false,
                valueString: defaultContent.displayString,
                contentTypeMatches: true
            ),
        ]
        #expect(values == expected)
    }


    @Test
    mutating func providerValuesMarksActiveAndContentTypeMatch() {
        // set up with a matching working copy override and a mismatched provider value
        let defaultContent = ConfigContent.string(randomAlphanumericString())
        let variable = randomRegisteredVariable(defaultContent: defaultContent)

        let mismatchedContent = ConfigContent.int(randomInt(in: .min ... .max))
        let provider = InMemoryProvider(
            values: [
                AbsoluteConfigKey(variable.key): ConfigValue(mismatchedContent, isSecret: false)
            ]
        )
        let providerDisplayName = randomAlphanumericString()

        let document = makeDocument(
            namedProviders: [.init(provider, displayName: providerDisplayName)],
            registeredVariables: [variable]
        )

        let overrideContent = ConfigContent.string(randomAlphanumericString())
        document.setOverride(overrideContent, forKey: variable.key)

        // exercise
        let values = document.providerValues(forKey: variable.key)

        // expect working copy active and matching, provider mismatched, default matching but inactive
        let expected = [
            ProviderValue(
                providerName: workingCopyDisplayName,
                providerIndex: nil,
                isActive: true,
                valueString: overrideContent.displayString,
                contentTypeMatches: true
            ),
            ProviderValue(
                providerName: providerDisplayName,
                providerIndex: 0,
                isActive: false,
                valueString: mismatchedContent.displayString,
                contentTypeMatches: false
            ),
            ProviderValue(
                providerName: localizedString("editor.defaultProviderName"),
                providerIndex: 1,
                isActive: false,
                valueString: defaultContent.displayString,
                contentTypeMatches: true
            ),
        ]
        #expect(values == expected)
    }


    @Test
    mutating func providerValuesReturnsEmptyForUnregisteredKey() {
        // set up
        let document = makeDocument()

        // exercise
        let values = document.providerValues(forKey: randomConfigKey())

        // expect empty for an unregistered key
        #expect(values.isEmpty)
    }


    // MARK: - Working Copy

    @Test
    mutating func setAndRemoveOverride() {
        // set up
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])

        let overrideContent = ConfigContent.string(randomAlphanumericString())

        // exercise set
        document.setOverride(overrideContent, forKey: variable.key)

        // expect override is present
        #expect(document.workingCopy[variable.key] == overrideContent)

        // exercise remove
        document.removeOverride(forKey: variable.key)

        // expect override is gone
        #expect(document.workingCopy[variable.key] == nil)
    }


    @Test
    mutating func setOverrideWithSameValueIsNoOp() {
        // set up with an existing override
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])

        let content = ConfigContent.string(randomAlphanumericString())
        document.setOverride(content, forKey: variable.key)
        undoManager.removeAllActions()

        // exercise by setting the same value again
        document.setOverride(content, forKey: variable.key)

        // expect no undo action was registered
        #expect(!undoManager.canUndo)
    }


    @Test
    mutating func removeAllOverrides() {
        // set up with multiple overrides
        let variable1 = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let variable2 = randomRegisteredVariable(defaultContent: .int(randomInt(in: .min ... .max)))
        let document = makeDocument(registeredVariables: [variable1, variable2])

        document.setOverride(.string(randomAlphanumericString()), forKey: variable1.key)
        document.setOverride(.int(randomInt(in: .min ... .max)), forKey: variable2.key)

        // exercise
        document.removeAllOverrides()

        // expect working copy is empty
        #expect(document.workingCopy.isEmpty)
    }


    @Test
    mutating func hasOverrideReturnsTrueWhenOverrideExists() {
        // set up
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])

        // expect false before setting an override
        #expect(!document.hasOverride(forKey: variable.key))

        // exercise
        document.setOverride(.string(randomAlphanumericString()), forKey: variable.key)

        // expect true after setting an override
        #expect(document.hasOverride(forKey: variable.key))
    }


    @Test
    mutating func overrideReturnsContentWhenOverrideExists() {
        // set up
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])

        // expect nil before setting an override
        #expect(document.override(forKey: variable.key) == nil)

        // exercise
        let content = ConfigContent.string(randomAlphanumericString())
        document.setOverride(content, forKey: variable.key)

        // expect the override content is returned
        #expect(document.override(forKey: variable.key) == content)
    }


    @Test
    mutating func removeOverrideForMissingKeyIsNoOp() {
        // set up
        let document = makeDocument()
        undoManager.removeAllActions()

        // exercise by removing an override for a key that has none
        document.removeOverride(forKey: randomConfigKey())

        // expect no undo action was registered
        #expect(!undoManager.canUndo)
    }


    @Test
    mutating func removeAllOverridesWhenEmptyIsNoOp() {
        // set up with no overrides
        let document = makeDocument()
        undoManager.removeAllActions()

        // exercise
        document.removeAllOverrides()

        // expect no undo action was registered
        #expect(!undoManager.canUndo)
    }


    @Test
    mutating func undoRemoveAllOverridesRestoresValues() async {
        // set up with multiple overrides, yielding to close the undo group before removing
        let variable1 = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let variable2 = randomRegisteredVariable(defaultContent: .int(randomInt(in: .min ... .max)))
        let document = makeDocument(registeredVariables: [variable1, variable2])

        let content1 = ConfigContent.string(randomAlphanumericString())
        let content2 = ConfigContent.int(randomInt(in: .min ... .max))
        document.setOverride(content1, forKey: variable1.key)
        document.setOverride(content2, forKey: variable2.key)
        await Task.yield()

        document.removeAllOverrides()

        // exercise
        undoManager.undo()

        // expect both overrides are restored
        #expect(document.workingCopy[variable1.key] == content1)
        #expect(document.workingCopy[variable2.key] == content2)
    }


    // MARK: - Undo/Redo

    @Test
    mutating func undoSetOverrideRestoresPreviousState() {
        // set up by setting an override on a fresh key
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])

        document.setOverride(.string(randomAlphanumericString()), forKey: variable.key)

        // exercise
        undoManager.undo()

        // expect the override is removed
        #expect(document.workingCopy[variable.key] == nil)
    }


    @Test
    mutating func undoSetOverrideRestoresOldValue() async {
        // set up by setting an override, yielding to close the undo group, then overwriting
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])

        let originalContent = ConfigContent.string(randomAlphanumericString())
        document.setOverride(originalContent, forKey: variable.key)
        await Task.yield()

        document.setOverride(.string(randomAlphanumericString()), forKey: variable.key)

        // exercise
        undoManager.undo()

        // expect the original value is restored
        #expect(document.workingCopy[variable.key] == originalContent)
    }


    @Test
    mutating func undoRemoveOverrideRestoresValue() async {
        // set up by setting an override, yielding to close the undo group, then removing
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])

        let content = ConfigContent.string(randomAlphanumericString())
        document.setOverride(content, forKey: variable.key)
        await Task.yield()

        document.removeOverride(forKey: variable.key)

        // exercise
        undoManager.undo()

        // expect the value is restored
        #expect(document.workingCopy[variable.key] == content)
    }


    // MARK: - Dirty Tracking and Save

    @Test
    mutating func dirtyTrackingReflectsWorkingCopyChanges() {
        // set up
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])

        // expect clean initially
        #expect(!document.isDirty)
        #expect(document.changedKeys.isEmpty)

        // exercise by adding an override
        document.setOverride(.string(randomAlphanumericString()), forKey: variable.key)

        // expect dirty with the changed key
        #expect(document.isDirty)
        #expect(document.changedKeys == [variable.key])
    }


    @Test
    mutating func saveCommitsToProviderAndResetsDirtyState() {
        // set up with an override
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])

        let overrideContent = ConfigContent.string(randomAlphanumericString())
        document.setOverride(overrideContent, forKey: variable.key)

        // exercise
        document.save()

        // expect dirty state is reset
        #expect(!document.isDirty)
        #expect(document.changedKeys.isEmpty)

        // expect the override was committed to the provider
        #expect(editorOverrideProvider.overrides[variable.key] == overrideContent)
    }


    @Test
    mutating func saveRemovesDeletedOverridesFromProvider() {
        // set up by saving an override, then removing it from the working copy
        let variable = randomRegisteredVariable(defaultContent: .string(randomAlphanumericString()))
        let document = makeDocument(registeredVariables: [variable])

        let content = ConfigContent.string(randomAlphanumericString())
        document.setOverride(content, forKey: variable.key)
        document.save()

        document.removeOverride(forKey: variable.key)

        // exercise
        document.save()

        // expect the override is removed from the provider
        #expect(!editorOverrideProvider.hasOverride(forKey: variable.key))
    }
}
