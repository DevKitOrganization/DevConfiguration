//
//  DevConfiguration.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 6/11/25.
//

import Foundation

/// Prepends the specified string with `"devconfiguration."`.
///
/// - Parameter suffix: The string that will have DevConfiguration’s reverse DNS prefix prepended to it.
@usableFromInline
func reverseDNSPrefixed(_ suffix: String) -> String {
    return "devconfiguration.\(suffix)"
}
