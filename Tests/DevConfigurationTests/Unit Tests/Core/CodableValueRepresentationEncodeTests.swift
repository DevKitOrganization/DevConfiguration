//
//  CodableValueRepresentationEncodeTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/5/2026.
//

import Configuration
import DevTesting
import Foundation
import Testing

@testable import DevConfiguration

struct CodableValueRepresentationEncodeTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func encodeToContentWithStringRepresentation() throws {
        // set up
        let string = randomAlphanumericString()
        let data = string.data(using: .utf8)!

        // exercise
        let content = try CodableValueRepresentation.string().encodeToContent(data)

        // expect
        #expect(content == .string(string))
    }


    @Test
    mutating func encodeToContentWithDataRepresentation() throws {
        // set up
        let bytes = randomBytes()
        let data = Data(bytes)

        // exercise
        let content = try CodableValueRepresentation.data.encodeToContent(data)

        // expect
        #expect(content == .bytes(bytes))
    }


    @Test
    func encodeToContentThrowsStringEncodingErrorForInvalidEncoding() throws {
        // set up — create data that is invalid for ASCII encoding (bytes > 127)
        let data = Data([0xFF, 0xFE])

        // exercise and expect
        #expect(throws: StringEncodingError.self) {
            try CodableValueRepresentation.string(encoding: .ascii).encodeToContent(data)
        }
    }


    @Test
    func stringEncodingErrorContainsEncoding() throws {
        // set up
        let data = Data([0xFF, 0xFE])

        // exercise
        do {
            _ = try CodableValueRepresentation.string(encoding: .ascii).encodeToContent(data)
            Issue.record("Expected StringEncodingError to be thrown")
        } catch let error as StringEncodingError {
            // expect
            #expect(error.encoding == .ascii)
        }
    }
}
