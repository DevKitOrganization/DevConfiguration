//
//  ConfigVariableListViewModeling.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/8/2026.
//

import Configuration
import Foundation

/// The view model protocol for the configuration variable list view.
///
/// `ConfigVariableListViewModeling` defines the interface that the list view uses to display and interact with
/// registered configuration variables. It provides a filtered and sorted list of variables, search functionality,
/// dirty tracking, undo/redo support, and the ability to save or cancel changes.
///
/// Conforming types must also provide a factory method for creating detail view models for individual variables.
@MainActor
protocol ConfigVariableListViewModeling: Observable {
    /// The type of detail view model created by ``makeDetailViewModel(for:)``.
    associatedtype DetailViewModel: ConfigVariableDetailViewModeling

    /// The filtered and sorted list of variables to display.
    var variables: [VariableListItem] { get }

    /// The current search text used to filter ``variables``.
    var searchText: String { get set }

    /// Whether the editor document has unsaved changes.
    var isDirty: Bool { get }

    /// Whether there is an undo action available.
    var canUndo: Bool { get }

    /// Whether there is a redo action available.
    var canRedo: Bool { get }

    /// Saves the current working copy and returns the registered variables whose overrides changed.
    func save() -> [RegisteredConfigVariable]

    /// Cancels editing, discarding any unsaved changes.
    func cancel()

    /// Removes all editor overrides from the working copy.
    func clearAllOverrides()

    /// Undoes the most recent change.
    func undo()

    /// Redoes the most recently undone change.
    func redo()

    /// Creates a detail view model for the variable with the given key.
    ///
    /// - Parameter key: The configuration key of the variable to inspect.
    /// - Returns: A detail view model for the variable.
    func makeDetailViewModel(for key: ConfigKey) -> DetailViewModel
}
