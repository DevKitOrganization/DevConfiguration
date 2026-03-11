//
//  EditorControlTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/11/2026.
//

import Configuration
import Testing

@testable import DevConfiguration

struct EditorControlTests {
    // MARK: - pickerOptions

    @Test
    func pickerOptionsReturnsOptionsForPicker() {
        // set up
        let options: [EditorControl.PickerOption] = [
            .init(label: "On", content: .bool(true)),
            .init(label: "Off", content: .bool(false)),
        ]

        // exercise
        let result = EditorControl.picker(options: options).pickerOptions

        // expect
        #expect(result == options)
    }


    @Test(
        arguments: [
            EditorControl.toggle,
            .textField,
            .numberField,
            .decimalField,
            .textEditor,
        ]
    )
    func pickerOptionsReturnsNilForNonPickerControls(control: EditorControl) {
        #expect(control.pickerOptions == nil)
    }
}
