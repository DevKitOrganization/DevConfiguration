//
//  CodableValueRepresentationTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/11/2026.
//

import Configuration
import DevTesting
import Foundation
import Testing

@testable import DevConfiguration

struct CodableValueRepresentationTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    // MARK: - data(from:)

    @Test
    mutating func dataFromStringRepresentationExtractsStringAsUTF8Data() {
        // set up
        let string = randomAlphanumericString()
        let representation = CodableValueRepresentation.string()

        // exercise
        let data = representation.data(from: .string(string))

        // expect
        #expect(data == Data(string.utf8))
    }


    @Test
    mutating func dataFromStringRepresentationReturnsNilForNonStringContent() {
        // set up
        let representation = CodableValueRepresentation.string()

        // exercise and expect
        #expect(representation.data(from: .int(randomInt(in: .min ... .max))) == nil)
    }


    @Test
    mutating func dataFromDataRepresentationExtractsBytesAsData() {
        // set up
        let bytes = randomBytes()
        let representation = CodableValueRepresentation.data

        // exercise
        let data = representation.data(from: .bytes(bytes))

        // expect
        #expect(data == Data(bytes))
    }


    @Test
    mutating func dataFromDataRepresentationReturnsNilForNonBytesContent() {
        // set up
        let representation = CodableValueRepresentation.data

        // exercise and expect
        #expect(representation.data(from: .string(randomAlphanumericString())) == nil)
    }


    // MARK: - supportsTextEditing

    @Test
    func supportsTextEditingReturnsTrueForStringRepresentation() {
        #expect(CodableValueRepresentation.string().supportsTextEditing)
    }


    @Test
    func supportsTextEditingReturnsFalseForDataRepresentation() {
        #expect(!CodableValueRepresentation.data.supportsTextEditing)
    }
}
