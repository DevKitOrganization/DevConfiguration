//
//  VariableSection.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 7/23/2026.
//

/// A titled section of variables to display in the configuration variable list view.
///
/// Each section corresponds to either a metadata group or the collection of variables that have no group. The
/// title is resolved by the view model, so the view can render it directly without any conditional logic.
struct VariableSection: Hashable, Sendable {
    /// The section's display title.
    let title: String

    /// The variables in this section.
    let items: [VariableListItem]
}
