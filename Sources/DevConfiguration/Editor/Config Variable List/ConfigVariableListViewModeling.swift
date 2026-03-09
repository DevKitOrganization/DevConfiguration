//
//  ConfigVariableListViewModeling.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/9/2026.
//

#if canImport(SwiftUI)

import Configuration
import Foundation

/// The interface for a configuration variable list view's view model.
///
/// `ConfigVariableListViewModeling` defines the minimal interface that ``ConfigVariableListView`` needs to display and
/// manage the list of configuration variables. The view binds to properties and calls methods on this protocol without
/// knowing the concrete implementation.
@MainActor
protocol ConfigVariableListViewModeling: Observable {
    /// The associated detail view model type.
    associatedtype DetailViewModel: ConfigVariableDetailViewModeling

    /// The filtered and sorted list of variable items to display.
    var variables: [VariableListItem] { get }

    /// The current search text for filtering variables.
    var searchText: String { get set }

    /// Whether the working copy has unsaved changes.
    var isDirty: Bool { get }

    /// Whether the undo manager can undo.
    var canUndo: Bool { get }

    /// Whether the undo manager can redo.
    var canRedo: Bool { get }

    /// Whether the save confirmation alert is showing.
    var isShowingSaveAlert: Bool { get set }

    /// Whether the clear overrides confirmation alert is showing.
    var isShowingClearAlert: Bool { get set }

    /// Requests dismissal of the editor.
    ///
    /// If the working copy has unsaved changes, this presents the save alert. Otherwise, it calls the dismiss closure
    /// immediately.
    ///
    /// - Parameter dismiss: A closure that dismisses the editor view.
    func requestDismiss(_ dismiss: () -> Void)

    /// Saves the working copy to the editor override provider.
    func save()

    /// Requests clearing all overrides by presenting the clear confirmation alert.
    func requestClearAllOverrides()

    /// Confirms clearing all overrides from the working copy.
    func confirmClearAllOverrides()

    /// Undoes the last working copy change.
    func undo()

    /// Redoes the last undone working copy change.
    func redo()

    /// Creates a detail view model for the variable with the given key.
    ///
    /// - Parameter key: The configuration key of the variable to display.
    /// - Returns: A detail view model for the variable.
    func makeDetailViewModel(for key: ConfigKey) -> DetailViewModel
}

#endif
