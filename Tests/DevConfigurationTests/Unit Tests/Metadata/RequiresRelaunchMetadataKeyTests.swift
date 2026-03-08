//
//  RequiresRelaunchMetadataKeyTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/7/2026.
//

import Testing

@testable import DevConfiguration

struct RequiresRelaunchMetadataKeyTests {
    @Test
    func requiresRelaunchDefaultsToFalseAndStoresAndRetrievesValue() {
        // set up
        var metadata = ConfigVariableMetadata()

        // expect that unset requiresRelaunch returns false
        #expect(metadata.requiresRelaunch == false)

        // exercise
        metadata.requiresRelaunch = true

        // expect that the value is stored and retrieved correctly
        #expect(metadata.requiresRelaunch == true)
    }


    @Test
    func requiresRelaunchDisplayTextShowsValue() throws {
        // set up
        var metadata = ConfigVariableMetadata()

        // exercise
        metadata.requiresRelaunch = true

        // expect that displayTextEntries contains the requires relaunch entry with a localized key
        let entries = metadata.displayTextEntries
        let entry = try #require(entries.first { $0.value == "true" })
        #expect(entry.key != "requiresRelaunchMetadata.keyDisplayText")
    }
}
