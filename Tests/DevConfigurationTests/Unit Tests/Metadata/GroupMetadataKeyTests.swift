//
//  GroupMetadataKeyTests.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 7/22/2026.
//

import Testing

@testable import DevConfiguration

struct GroupMetadataKeyTests {
    @Test
    func groupDefaultsToNilAndStoresAndRetrievesValue() {
        // set up
        var metadata = ConfigVariableMetadata()

        // expect that unset group returns nil
        #expect(metadata.group == nil)

        // exercise
        let group = ConfigVariableGroup("Networking")
        metadata.group = group

        // expect that the value is stored and retrieved correctly
        #expect(metadata.group == group)
    }


    @Test
    func groupDisplayTextShowsRawValue() throws {
        // set up
        var metadata = ConfigVariableMetadata()
        let group = ConfigVariableGroup("Networking")

        // exercise
        metadata.group = group

        // expect that displayTextEntries contains the group entry with the rawValue
        let entries = metadata.displayTextEntries
        let entry = try #require(entries.first { $0.value == "Networking" })
        #expect(entry.key != "groupMetadata.keyDisplayText")
    }


    @Test
    func groupDisplayTextReturnsNilForNilValue() {
        // set up
        var metadata = ConfigVariableMetadata()

        // expect that unset group produces no display text entry
        #expect(metadata.group == nil)
        #expect(metadata.displayTextEntries.isEmpty)
    }


    @Test
    func configVariableGroupComparableSortsAlphabetically() {
        // set up
        let alpha = ConfigVariableGroup("Alpha")
        let beta = ConfigVariableGroup("Beta")
        let charlie = ConfigVariableGroup("Charlie")

        // exercise
        let sorted = [charlie, alpha, beta].sorted()

        // expect alphabetical order
        #expect(sorted == [alpha, beta, charlie])
    }


    @Test
    func configVariableGroupEquality() {
        // set up
        let a = ConfigVariableGroup("Networking")
        let b = ConfigVariableGroup("Networking")
        let c = ConfigVariableGroup("Other")

        // expect equality based on rawValue
        #expect(a == b)
        #expect(a != c)
    }
}
