//
//  ProviderValue.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/8/2026.
//

/// A data structure representing a single provider's value for a configuration variable in the detail view.
///
/// Each `ProviderValue` contains the provider's name and the value it has for the variable formatted as a display
/// string.
struct ProviderValue: Hashable, Sendable {
    /// The name of the provider.
    let providerName: String

    /// The index of the provider in the reader's provider list, used for color assignment.
    let providerIndex: Int

    /// Whether this provider is the one currently supplying the resolved value.
    let isActive: Bool

    /// The provider's value for the variable, formatted as a display string.
    let valueString: String
}
