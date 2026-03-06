//
//  MockConfigIntValue.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/5/2026.
//

import Configuration

struct MockConfigIntValue: ExpressibleByConfigInt, Hashable, Sendable {
    let intValue: Int
    var configInt: Int { intValue }
    var description: String { "\(intValue)" }

    init?(configInt: Int) {
        self.intValue = configInt
    }
}
