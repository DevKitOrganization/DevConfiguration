//
//  String+NonEmptyTrimmedLines.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/10/2026.
//

import Foundation

extension String {
    /// The non-empty lines of the string, each trimmed of leading and trailing whitespace.
    var nonEmptyTrimmedLines: [String] {
        split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
