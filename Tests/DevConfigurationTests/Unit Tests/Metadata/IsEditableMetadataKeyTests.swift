//
//  IsEditableMetadataKeyTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/17/2026.
//

import Testing

@testable import DevConfiguration

struct IsEditableMetadataKeyTests {
    @Test
    func isEditableDefaultsToTrueAndStoresAndRetrievesValue() {
        // set up
        var metadata = ConfigVariableMetadata()

        // expect that unset isEditable returns true
        #expect(metadata.isEditable)

        // exercise
        metadata.isEditable = false

        // expect that the value is stored and retrieved correctly
        #expect(!metadata.isEditable)
    }


    @Test
    func isEditableDisplayTextShowsValue() throws {
        // set up
        var metadata = ConfigVariableMetadata()

        // exercise
        metadata.isEditable = false

        // expect that displayTextEntries contains the is editable entry with a localized key
        let entries = metadata.displayTextEntries
        let entry = try #require(entries.first { $0.value == "false" })
        #expect(entry.key != "isEditableMetadata.keyDisplayText")
    }
}
