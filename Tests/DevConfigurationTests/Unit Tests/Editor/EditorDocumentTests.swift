//
//  EditorDocumentTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/7/2026.
//

import Configuration
import DevTesting
import Foundation
import Testing

@testable import DevConfiguration

@MainActor
struct EditorDocumentTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    // MARK: - Init

    @Test
    func initWithEmptyProvider() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)

        // expect
        #expect(document.workingCopy.isEmpty)
        #expect(!document.isDirty)
    }


    @Test
    mutating func initWithPopulatedProvider() {
        // set up
        let provider = EditorOverrideProvider()
        let key1 = randomConfigKey()
        let content1 = randomConfigContent()
        let key2 = randomConfigKey()
        let content2 = randomConfigContent()
        provider.setOverride(content1, forKey: key1)
        provider.setOverride(content2, forKey: key2)

        // exercise
        let document = EditorDocument(provider: provider)

        // expect
        #expect(document.workingCopy == [key1: content1, key2: content2])
        #expect(!document.isDirty)
    }


    // MARK: - Working Copy

    @Test
    mutating func setOverrideThenRetrieve() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        let key = randomConfigKey()
        let content = randomConfigContent()

        // exercise
        document.setOverride(content, forKey: key)

        // expect
        #expect(document.override(forKey: key) == content)
    }


    @Test
    mutating func setOverrideOverwritesPreviousValue() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        let key = randomConfigKey()
        let content1 = ConfigContent.string(randomAlphanumericString())
        let content2 = ConfigContent.int(randomInt(in: .min ... .max))

        document.setOverride(content1, forKey: key)

        // exercise
        document.setOverride(content2, forKey: key)

        // expect
        #expect(document.override(forKey: key) == content2)
    }


    @Test
    mutating func overrideForNonexistentKeyReturnsNil() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)

        // expect
        #expect(document.override(forKey: randomConfigKey()) == nil)
    }


    @Test
    mutating func hasOverrideReturnsTrueForExistingKey() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        let key = randomConfigKey()
        document.setOverride(randomConfigContent(), forKey: key)

        // expect
        #expect(document.hasOverride(forKey: key))
    }


    @Test
    mutating func hasOverrideReturnsFalseForNonexistentKey() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)

        // expect
        #expect(!document.hasOverride(forKey: randomConfigKey()))
    }


    @Test
    mutating func removeOverrideClearsValue() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        let key = randomConfigKey()
        document.setOverride(randomConfigContent(), forKey: key)

        // exercise
        document.removeOverride(forKey: key)

        // expect
        #expect(document.override(forKey: key) == nil)
        #expect(!document.hasOverride(forKey: key))
    }


    @Test
    mutating func removeOverrideForNonexistentKeyIsNoOp() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        let key = randomConfigKey()
        document.setOverride(randomConfigContent(), forKey: key)

        // exercise
        document.removeOverride(forKey: randomConfigKey())

        // expect — original override is untouched
        #expect(document.workingCopy.count == 1)
    }


    @Test
    mutating func removeAllOverridesClearsWorkingCopy() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        document.setOverride(randomConfigContent(), forKey: randomConfigKey())
        document.setOverride(randomConfigContent(), forKey: randomConfigKey())

        // exercise
        document.removeAllOverrides()

        // expect
        #expect(document.workingCopy.isEmpty)
    }


    @Test
    func removeAllOverridesWhenEmptyIsNoOp() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)

        // exercise
        document.removeAllOverrides()

        // expect
        #expect(document.workingCopy.isEmpty)
        #expect(!document.isDirty)
    }


    // MARK: - Dirty Tracking

    @Test
    func isNotDirtyAfterInit() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)

        // expect
        #expect(!document.isDirty)
    }


    @Test
    mutating func isDirtyAfterSetOverride() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)

        // exercise
        document.setOverride(randomConfigContent(), forKey: randomConfigKey())

        // expect
        #expect(document.isDirty)
    }


    @Test
    mutating func isNotDirtyAfterRevertingToBaseline() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        let key = randomConfigKey()

        document.setOverride(randomConfigContent(), forKey: key)
        #expect(document.isDirty)

        // exercise
        document.removeOverride(forKey: key)

        // expect
        #expect(!document.isDirty)
    }


    @Test
    mutating func isDirtyAfterRemovingBaselineOverride() {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        provider.setOverride(randomConfigContent(), forKey: key)
        let document = EditorDocument(provider: provider)

        // exercise
        document.removeOverride(forKey: key)

        // expect
        #expect(document.isDirty)
    }


    @Test
    mutating func isDirtyAfterChangingBaselineValue() {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        provider.setOverride(.bool(true), forKey: key)
        let document = EditorDocument(provider: provider)

        // exercise
        document.setOverride(.bool(false), forKey: key)

        // expect
        #expect(document.isDirty)
    }


    @Test
    func changedKeysIsEmptyAfterInit() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)

        // expect
        #expect(document.changedKeys.isEmpty)
    }


    @Test
    mutating func changedKeysIncludesAddedKey() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        let key = randomConfigKey()

        // exercise
        document.setOverride(randomConfigContent(), forKey: key)

        // expect
        #expect(document.changedKeys == [key])
    }


    @Test
    mutating func changedKeysIncludesRemovedKey() {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        provider.setOverride(randomConfigContent(), forKey: key)
        let document = EditorDocument(provider: provider)

        // exercise
        document.removeOverride(forKey: key)

        // expect
        #expect(document.changedKeys == [key])
    }


    @Test
    mutating func changedKeysIncludesModifiedKey() {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        provider.setOverride(.bool(true), forKey: key)
        let document = EditorDocument(provider: provider)

        // exercise
        document.setOverride(.bool(false), forKey: key)

        // expect
        #expect(document.changedKeys == [key])
    }


    @Test
    mutating func changedKeysExcludesUnchangedKey() {
        // set up
        let provider = EditorOverrideProvider()
        let unchangedKey = randomConfigKey()
        let changedKey = randomConfigKey()
        provider.setOverride(.bool(true), forKey: unchangedKey)
        let document = EditorDocument(provider: provider)

        // exercise
        document.setOverride(randomConfigContent(), forKey: changedKey)

        // expect
        #expect(document.changedKeys == [changedKey])
    }


    // MARK: - Save

    @Test
    mutating func saveReturnsChangedKeys() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        let key1 = randomConfigKey()
        let key2 = randomConfigKey()
        document.setOverride(randomConfigContent(), forKey: key1)
        document.setOverride(randomConfigContent(), forKey: key2)

        // exercise
        let changed = document.save()

        // expect
        #expect(changed == [key1, key2])
    }


    @Test
    mutating func saveResetsBaselineSoDocumentIsClean() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        document.setOverride(randomConfigContent(), forKey: randomConfigKey())
        #expect(document.isDirty)

        // exercise
        document.save()

        // expect
        #expect(!document.isDirty)
        #expect(document.changedKeys.isEmpty)
    }


    @Test
    mutating func saveUpdatesProviderOverrides() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        let key = randomConfigKey()
        let content = randomConfigContent()
        document.setOverride(content, forKey: key)

        // exercise
        document.save()

        // expect
        #expect(provider.overrides == [key: content])
    }


    @Test
    mutating func savePersistsToUserDefaults() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        let key = randomConfigKey()
        let content = randomConfigContent()
        document.setOverride(content, forKey: key)

        // exercise
        document.save()

        // expect — verify persistence by loading into a fresh provider
        let freshProvider = EditorOverrideProvider()
        freshProvider.load(from: UserDefaults(suiteName: EditorOverrideProvider.suiteName)!)
        #expect(freshProvider.overrides[key] == content)

        // clean up
        provider.clearPersistence(from: UserDefaults(suiteName: EditorOverrideProvider.suiteName)!)
    }


    @Test
    func saveWithNoChangesReturnsEmptySet() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)

        // exercise
        let changed = document.save()

        // expect
        #expect(changed.isEmpty)
    }


    @Test
    mutating func saveWithRemovedBaselineKeyIncludesItInChangedKeys() {
        // set up
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        provider.setOverride(randomConfigContent(), forKey: key)
        let document = EditorDocument(provider: provider)
        document.removeOverride(forKey: key)

        // exercise
        let changed = document.save()

        // expect
        #expect(changed == [key])
        #expect(provider.overrides.isEmpty)
    }


    // MARK: - Undo/Redo

    @Test
    mutating func undoSetOverrideRestoresPreviousValue() {
        // set up
        let undoManager = UndoManager()
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        let originalContent = ConfigContent.string(randomAlphanumericString())
        provider.setOverride(originalContent, forKey: key)
        let document = EditorDocument(provider: provider, undoManager: undoManager)

        document.setOverride(.bool(true), forKey: key)
        #expect(document.override(forKey: key) == .bool(true))

        // exercise
        undoManager.undo()

        // expect
        #expect(document.override(forKey: key) == originalContent)
    }


    @Test
    mutating func undoSetOverrideRemovesNewKey() {
        // set up
        let undoManager = UndoManager()
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider, undoManager: undoManager)
        let key = randomConfigKey()

        document.setOverride(randomConfigContent(), forKey: key)
        #expect(document.hasOverride(forKey: key))

        // exercise
        undoManager.undo()

        // expect
        #expect(!document.hasOverride(forKey: key))
    }


    @Test
    mutating func redoSetOverrideReapplies() {
        // set up
        let undoManager = UndoManager()
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider, undoManager: undoManager)
        let key = randomConfigKey()
        let content = randomConfigContent()

        document.setOverride(content, forKey: key)
        undoManager.undo()
        #expect(!document.hasOverride(forKey: key))

        // exercise
        undoManager.redo()

        // expect
        #expect(document.override(forKey: key) == content)
    }


    @Test
    mutating func undoRemoveOverrideRestoresValue() {
        // set up
        let undoManager = UndoManager()
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        let content = randomConfigContent()
        provider.setOverride(content, forKey: key)
        let document = EditorDocument(provider: provider, undoManager: undoManager)

        document.removeOverride(forKey: key)
        #expect(!document.hasOverride(forKey: key))

        // exercise
        undoManager.undo()

        // expect
        #expect(document.override(forKey: key) == content)
    }


    @Test
    mutating func redoRemoveOverrideRemovesAgain() {
        // set up
        let undoManager = UndoManager()
        let provider = EditorOverrideProvider()
        let key = randomConfigKey()
        let content = randomConfigContent()
        provider.setOverride(content, forKey: key)
        let document = EditorDocument(provider: provider, undoManager: undoManager)

        document.removeOverride(forKey: key)
        undoManager.undo()
        #expect(document.hasOverride(forKey: key))

        // exercise
        undoManager.redo()

        // expect
        #expect(!document.hasOverride(forKey: key))
    }


    @Test
    mutating func undoRemoveAllOverridesRestoresAll() {
        // set up
        let undoManager = UndoManager()
        let provider = EditorOverrideProvider()
        let key1 = randomConfigKey()
        let content1 = randomConfigContent()
        let key2 = randomConfigKey()
        let content2 = randomConfigContent()
        provider.setOverride(content1, forKey: key1)
        provider.setOverride(content2, forKey: key2)
        let document = EditorDocument(provider: provider, undoManager: undoManager)

        document.removeAllOverrides()
        #expect(document.workingCopy.isEmpty)

        // exercise
        undoManager.undo()

        // expect
        #expect(document.workingCopy == [key1: content1, key2: content2])
    }


    @Test
    mutating func redoRemoveAllOverridesClearsAgain() {
        // set up
        let undoManager = UndoManager()
        let provider = EditorOverrideProvider()
        let key1 = randomConfigKey()
        let content1 = randomConfigContent()
        let key2 = randomConfigKey()
        let content2 = randomConfigContent()
        provider.setOverride(content1, forKey: key1)
        provider.setOverride(content2, forKey: key2)
        let document = EditorDocument(provider: provider, undoManager: undoManager)

        document.removeAllOverrides()
        undoManager.undo()
        #expect(document.workingCopy.count == 2)

        // exercise
        undoManager.redo()

        // expect
        #expect(document.workingCopy.isEmpty)
    }


    @Test
    mutating func noUndoManagerDoesNotCrash() {
        // set up
        let provider = EditorOverrideProvider()
        let document = EditorDocument(provider: provider)
        let key = randomConfigKey()

        // exercise — all mutations should work without an undo manager
        document.setOverride(randomConfigContent(), forKey: key)
        document.removeOverride(forKey: key)
        document.setOverride(randomConfigContent(), forKey: key)
        document.removeAllOverrides()

        // expect
        #expect(document.workingCopy.isEmpty)
    }
}
