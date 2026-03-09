//
//  DisplayNameMetadataKeyTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/7/2026.
//

import DevTesting
import Testing

@testable import DevConfiguration

struct DisplayNameMetadataKeyTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func displayNameDefaultsToNilAndStoresAndRetrievesValue() {
        // set up
        var metadata = ConfigVariableMetadata()

        // expect that unset display name returns nil
        #expect(metadata.displayName == nil)

        // exercise
        let name = randomAlphanumericString()
        metadata.displayName = name

        // expect that the value is stored and retrieved correctly
        #expect(metadata.displayName == name)
    }


    @Test
    mutating func displayNameDisplayTextShowsValue() throws {
        // set up
        var metadata = ConfigVariableMetadata()
        let name = randomAlphanumericString()

        // exercise
        metadata.displayName = name

        // expect that displayTextEntries contains the display name entry with a localized key
        let entries = metadata.displayTextEntries
        let entry = try #require(entries.first { $0.value == name })
        #expect(entry.key != "displayNameMetadata.keyDisplayText")
    }
}
