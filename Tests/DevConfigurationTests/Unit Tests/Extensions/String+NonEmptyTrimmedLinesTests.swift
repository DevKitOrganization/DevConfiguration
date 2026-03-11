//
//  String+NonEmptyTrimmedLinesTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/11/2026.
//

import Foundation
import Testing

@testable import DevConfiguration

struct String_NonEmptyTrimmedLinesTests {
    @Test
    func emptyStringReturnsEmptyArray() {
        #expect("".nonEmptyTrimmedLines == [])
    }


    @Test
    func singleLineReturnsTrimmedElement() {
        #expect("  hello  ".nonEmptyTrimmedLines == ["hello"])
    }


    @Test
    func multipleLinesReturnsTrimmedElements() {
        #expect("one\ntwo\nthree".nonEmptyTrimmedLines == ["one", "two", "three"])
    }


    @Test
    func blankLinesAreFilteredOut() {
        #expect("one\n\n  \ntwo".nonEmptyTrimmedLines == ["one", "two"])
    }


    @Test
    func leadingAndTrailingWhitespaceOnLinesIsTrimmed() {
        #expect("  alpha  \n  beta  ".nonEmptyTrimmedLines == ["alpha", "beta"])
    }
}
