//
//  ProviderBadge.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/8/2026.
//

#if canImport(SwiftUI)

import SwiftUI

/// A small colored badge that displays a configuration provider's name.
///
/// `ProviderBadge` is used in the editor's list and detail views to visually identify which provider owns a
/// configuration value. The badge color is assigned deterministically based on the provider's index in the reader's
/// provider list.
struct ProviderBadge: View {
    /// The name of the provider to display.
    let providerName: String

    /// The color to use for the badge.
    let color: Color


    var body: some View {
        Text(providerName)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .foregroundStyle(.white)
            .background(color, in: .capsule)
    }
}


/// Returns a color for the provider at the given index.
///
/// Colors are assigned from a fixed palette and wrap around if there are more providers than colors.
///
/// - Parameter index: The provider's index in the reader's provider list.
/// - Returns: A color for the provider.
func providerColor(at index: Int) -> Color {
    let palette: [Color] = [.blue, .green, .yellow, .orange, .red, .indigo, .purple, .mint, .cyan]
    return palette[index % palette.count]
}


#Preview {
    VStack(spacing: 8) {
        ForEach(Array(0 ..< 9), id: \.self) { index in
            ProviderBadge(providerName: "Provider \(index)", color: providerColor(at: index))
        }
    }
    .padding()
}

#endif
