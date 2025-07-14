//
//  DevConfigurationTests.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 7/11/25.
//

import DevTesting
import Foundation
import Testing
@testable import DevConfiguration

struct DevConfigurationTests {
    @Test
    func testReverseDNSPrefix() {
        let result = reverseDNSPrefixed("test")
        #expect(result == "com.gauriar.devconfiguration.test")
    }
}
