//
//  EditorControl.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/7/2026.
//

/// Describes which UI control the editor should use to edit a configuration variable's value.
///
/// Each ``ConfigVariableContent`` instance has an associated `EditorControl` that tells the editor UI which input
/// control to present when the user enables an override. Content factories set this automatically based on the
/// variable's value type.
public struct EditorControl: Hashable, Sendable {
    /// The underlying kinds of editor controls.
    private enum Kind: Hashable, Sendable {
        case toggle
        case textField
        case numberField
        case decimalField
        case none
    }


    /// The underlying kind of this editor control.
    private let kind: Kind
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

    /// No editor control.
    ///
    /// The variable is read-only in the editor.
    public static var none: EditorControl {
        EditorControl(kind: .none)
    }
}
