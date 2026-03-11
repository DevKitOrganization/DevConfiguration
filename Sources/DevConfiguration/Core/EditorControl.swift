//
//  EditorControl.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/7/2026.
//

import Configuration

/// Describes which UI control the editor should use to edit a configuration variable's value.
///
/// Each ``ConfigVariableContent`` instance has an associated `EditorControl` that tells the editor UI which input
/// control to present when the user enables an override. Content factories set this automatically based on the
/// variable's value type.
public struct EditorControl: Hashable, Sendable {
    /// A single option in a picker control.
    public struct PickerOption: Hashable, Sendable {
        /// The human-readable label for this option.
        public let label: String

        /// The configuration content value this option represents.
        public let content: ConfigContent
    }


    /// The underlying kinds of editor controls.
    enum Kind: Hashable, Sendable {
        case toggle
        case textField
        case numberField
        case decimalField
        case textEditor
        case picker([PickerOption])
    }


    /// The underlying kind of this editor control.
    let kind: Kind
}


extension EditorControl {
    /// A toggle control, used for `Bool` values.
    public static var toggle: EditorControl {
        EditorControl(kind: .toggle)
    }


    /// A text field control, used for `String` and string-backed values.
    public static var textField: EditorControl {
        EditorControl(kind: .textField)
    }


    /// A number field control, used for `Int` and integer-backed values.
    ///
    /// Rejects fractional input.
    public static var numberField: EditorControl {
        EditorControl(kind: .numberField)
    }


    /// A decimal field control, used for `Float64` values.
    ///
    /// Allows fractional input.
    public static var decimalField: EditorControl {
        EditorControl(kind: .decimalField)
    }


    /// A text editor control, used for multi-line content like JSON or arrays.
    public static var textEditor: EditorControl {
        EditorControl(kind: .textEditor)
    }


    /// A picker control, used for `CaseIterable` types with a fixed set of valid values.
    ///
    /// - Parameter options: The available picker options with their labels and content values.
    public static func picker(options: [PickerOption]) -> EditorControl {
        EditorControl(kind: .picker(options))
    }


    /// The picker options, if this is a picker control.
    ///
    /// Returns `nil` for non-picker controls.
    public var pickerOptions: [PickerOption]? {
        guard case .picker(let options) = kind else {
            return nil
        }
        return options
    }
}
