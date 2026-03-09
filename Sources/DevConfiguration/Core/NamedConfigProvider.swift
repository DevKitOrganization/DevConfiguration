//
//  NamedConfigProvider.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/8/2026.
//

import Configuration

/// A configuration provider paired with a human-readable display name.
///
/// Use `NamedConfigProvider` when adding providers to a ``ConfigVariableReader`` to control how the provider's name
/// appears in the editor UI. If no display name is specified, the provider's ``ConfigProvider/providerName`` is used.
///
///     let reader = ConfigVariableReader(
///         providers: [
///             NamedConfigProvider(environmentProvider, displayName: "Environment"),
///             NamedConfigProvider(remoteProvider)
///         ],
///         eventBus: eventBus
///     )
public struct NamedConfigProvider: Sendable {
    /// The configuration provider.
    public let provider: any ConfigProvider

    /// The human-readable display name for this provider.
    public let displayName: String


    /// Creates a named configuration provider.
    ///
    /// - Parameters:
    ///   - provider: The configuration provider.
    ///   - displayName: A human-readable display name. If `nil`, the provider's `providerName` is used.
    public init(_ provider: any ConfigProvider, displayName: String? = nil) {
        self.provider = provider
        self.displayName = displayName ?? provider.providerName
    }
}
