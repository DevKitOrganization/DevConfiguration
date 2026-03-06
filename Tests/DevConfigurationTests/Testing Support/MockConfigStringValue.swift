//
//  MockConfigStringValue.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/5/2026.
//

import Configuration

struct MockConfigStringValue: ExpressibleByConfigString, Hashable, Sendable {
    let stringValue: String
    var description: String { stringValue }

    init?(configString: String) {
        self.stringValue = configString
    }
}
