//
//  ConfigVariableContentEditorTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/7/2026.
//

import Configuration
import DevTesting
import Foundation
import Testing

@testable import DevConfiguration

struct ConfigVariableContentEditorTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    // MARK: - Editor Control

    @Test
    func boolEditorControlIsToggle() {
        #expect(ConfigVariableContent<Bool>.bool.editorControl == .toggle)
    }


    @Test
    func float64EditorControlIsDecimalField() {
        #expect(ConfigVariableContent<Float64>.float64.editorControl == .decimalField)
    }


    @Test
    func intEditorControlIsNumberField() {
        #expect(ConfigVariableContent<Int>.int.editorControl == .numberField)
    }


    @Test
    func stringEditorControlIsTextField() {
        #expect(ConfigVariableContent<String>.string.editorControl == .textField)
    }


    @Test
    func bytesEditorControlIsNone() {
        #expect(ConfigVariableContent<[UInt8]>.bytes.editorControl == .none)
    }


    @Test
    func byteChunkArrayEditorControlIsNone() {
        #expect(ConfigVariableContent<[[UInt8]]>.byteChunkArray.editorControl == .none)
    }


    @Test
    func rawRepresentableStringEditorControlIsTextField() {
        let content = ConfigVariableContent<MockNonIterableStringEnum>.rawRepresentableString()
        #expect(content.editorControl == .textField)
    }


    @Test
    func rawRepresentableIntEditorControlIsNumberField() {
        let content = ConfigVariableContent<MockNonIterableIntEnum>.rawRepresentableInt()
        #expect(content.editorControl == .numberField)
    }


    @Test
    func expressibleByConfigStringEditorControlIsTextField() {
        let content = ConfigVariableContent<MockConfigStringValue>.expressibleByConfigString()
        #expect(content.editorControl == .textField)
    }


    @Test
    func expressibleByConfigIntEditorControlIsNumberField() {
        let content = ConfigVariableContent<MockConfigIntValue>.expressibleByConfigInt()
        #expect(content.editorControl == .numberField)
    }


    @Test
    func propertyListEditorControlIsNone() {
        let content = ConfigVariableContent<MockCodableValue>.propertyList()
        #expect(content.editorControl == .none)
    }


    // MARK: - Parse

    @Test
    func boolParseReturnsBoolContentForValidInput() {
        let parse = ConfigVariableContent<Bool>.bool.parse
        #expect(parse?("true") == .bool(true))
        #expect(parse?("false") == .bool(false))
    }


    @Test
    func boolParseReturnsNilForInvalidInput() {
        let parse = ConfigVariableContent<Bool>.bool.parse
        #expect(parse?("notABool") == nil)
    }


    @Test
    func float64ParseReturnsDoubleContentForValidInput() {
        let parse = ConfigVariableContent<Float64>.float64.parse
        #expect(parse?("3.14") == .double(3.14))
        #expect(parse?("42") == .double(42.0))
    }


    @Test
    func float64ParseReturnsDoubleContentForFormattedInput() {
        let parse = ConfigVariableContent<Float64>.float64.parse
        #expect(parse?(Float64(1234.5).formatted()) == .double(1234.5))
    }


    @Test
    func float64ParseReturnsNilForInvalidInput() {
        let parse = ConfigVariableContent<Float64>.float64.parse
        #expect(parse?("notANumber") == nil)
    }


    @Test
    mutating func intParseReturnsIntContentForValidInput() {
        let parse = ConfigVariableContent<Int>.int.parse
        let value = randomInt(in: -1000 ... 1000)
        #expect(parse?(String(value)) == .int(value))
    }


    @Test
    func intParseReturnsIntContentForFormattedInput() {
        let parse = ConfigVariableContent<Int>.int.parse
        #expect(parse?(1_234_567.formatted()) == .int(1_234_567))
    }


    @Test
    func intParseReturnsNilForInvalidInput() {
        let parse = ConfigVariableContent<Int>.int.parse
        #expect(parse?("3.14") == nil)
        #expect(parse?("notANumber") == nil)
    }


    @Test
    mutating func stringParseReturnsStringContent() {
        let parse = ConfigVariableContent<String>.string.parse
        let value = randomAlphanumericString()
        #expect(parse?(value) == .string(value))
    }


    @Test
    mutating func rawRepresentableStringParseReturnsStringContent() {
        let parse = ConfigVariableContent<MockNonIterableStringEnum>.rawRepresentableString().parse
        let value = randomAlphanumericString()
        #expect(parse?(value) == .string(value))
    }


    @Test
    mutating func rawRepresentableIntParseReturnsIntContentForValidInput() {
        let parse = ConfigVariableContent<MockNonIterableIntEnum>.rawRepresentableInt().parse
        let value = randomInt(in: -1000 ... 1000)
        #expect(parse?(String(value)) == .int(value))
    }


    @Test
    mutating func expressibleByConfigStringParseReturnsStringContent() {
        let parse = ConfigVariableContent<MockConfigStringValue>.expressibleByConfigString().parse
        let value = randomAlphanumericString()
        #expect(parse?(value) == .string(value))
    }


    @Test
    mutating func expressibleByConfigIntParseReturnsIntContentForValidInput() {
        let parse = ConfigVariableContent<MockConfigIntValue>.expressibleByConfigInt().parse
        let value = randomInt(in: -1000 ... 1000)
        #expect(parse?(String(value)) == .int(value))
    }


    @Test
    func bytesAndByteChunkArrayParseIsNil() {
        #expect(ConfigVariableContent<[UInt8]>.bytes.parse == nil)
        #expect(ConfigVariableContent<[[UInt8]]>.byteChunkArray.parse == nil)
    }


    @Test
    func propertyListParseIsNil() {
        #expect(ConfigVariableContent<MockCodableValue>.propertyList().parse == nil)
    }


    // MARK: - Array Parse

    @Test
    func boolArrayParseReturnsContentForValidInput() {
        let parse = ConfigVariableContent<[Bool]>.boolArray.parse
        #expect(parse?("true\nfalse\ntrue") == .boolArray([true, false, true]))
    }


    @Test
    func boolArrayParseReturnsNilForInvalidInput() {
        let parse = ConfigVariableContent<[Bool]>.boolArray.parse
        #expect(parse?("true\nnotABool") == nil)
    }


    @Test
    func float64ArrayParseReturnsContentForValidInput() {
        let parse = ConfigVariableContent<[Float64]>.float64Array.parse
        #expect(parse?("1.5\n2.5") == .doubleArray([1.5, 2.5]))
    }


    @Test
    func float64ArrayParseReturnsContentForFormattedInput() {
        let parse = ConfigVariableContent<[Float64]>.float64Array.parse
        let input = [Float64(1234.5), Float64(6789.1)].map { $0.formatted() }.joined(separator: "\n")
        #expect(parse?(input) == .doubleArray([1234.5, 6789.1]))
    }


    @Test
    func float64ArrayParseReturnsNilForInvalidInput() {
        let parse = ConfigVariableContent<[Float64]>.float64Array.parse
        #expect(parse?("1.5\nnotANumber") == nil)
    }


    @Test
    func intArrayParseReturnsContentForValidInput() {
        let parse = ConfigVariableContent<[Int]>.intArray.parse
        #expect(parse?("1\n2\n3") == .intArray([1, 2, 3]))
    }


    @Test
    func intArrayParseReturnsContentForFormattedInput() {
        let parse = ConfigVariableContent<[Int]>.intArray.parse
        let input = [1_234, 5_678].map { $0.formatted() }.joined(separator: "\n")
        #expect(parse?(input) == .intArray([1_234, 5_678]))
    }


    @Test
    func intArrayParseReturnsNilForInvalidInput() {
        let parse = ConfigVariableContent<[Int]>.intArray.parse
        #expect(parse?("1\nnotAnInt") == nil)
    }


    @Test
    func stringArrayParseReturnsContent() {
        let parse = ConfigVariableContent<[String]>.stringArray.parse
        #expect(parse?("a\nb\nc") == .stringArray(["a", "b", "c"]))
    }


    @Test
    func rawRepresentableStringArrayParseReturnsContent() {
        let parse = ConfigVariableContent<[MockNonIterableStringEnum]>.rawRepresentableStringArray().parse
        #expect(parse?("a\nb") == .stringArray(["a", "b"]))
    }


    @Test
    func rawRepresentableIntParseReturnsIntContentForFormattedInput() {
        let parse = ConfigVariableContent<MockNonIterableIntEnum>.rawRepresentableInt().parse
        #expect(parse?(1_234_567.formatted()) == .int(1_234_567))
    }


    @Test
    func rawRepresentableIntArrayParseReturnsContentForValidInput() {
        let parse = ConfigVariableContent<[MockNonIterableIntEnum]>.rawRepresentableIntArray().parse
        #expect(parse?("0\n1") == .intArray([0, 1]))
    }


    @Test
    func rawRepresentableIntArrayParseReturnsContentForFormattedInput() {
        let parse = ConfigVariableContent<[MockNonIterableIntEnum]>.rawRepresentableIntArray().parse
        let input = [1_234, 5_678].map { $0.formatted() }.joined(separator: "\n")
        #expect(parse?(input) == .intArray([1_234, 5_678]))
    }


    @Test
    func rawRepresentableIntArrayParseReturnsNilForInvalidInput() {
        let parse = ConfigVariableContent<[MockNonIterableIntEnum]>.rawRepresentableIntArray().parse
        #expect(parse?("0\nnotAnInt") == nil)
    }


    @Test
    func expressibleByConfigStringArrayParseReturnsContent() {
        let parse = ConfigVariableContent<[MockConfigStringValue]>.expressibleByConfigStringArray().parse
        #expect(parse?("x\ny") == .stringArray(["x", "y"]))
    }


    @Test
    func expressibleByConfigIntParseReturnsIntContentForFormattedInput() {
        let parse = ConfigVariableContent<MockConfigIntValue>.expressibleByConfigInt().parse
        #expect(parse?(1_234_567.formatted()) == .int(1_234_567))
    }


    @Test
    func expressibleByConfigIntArrayParseReturnsContentForValidInput() {
        let parse = ConfigVariableContent<[MockConfigIntValue]>.expressibleByConfigIntArray().parse
        #expect(parse?("10\n20") == .intArray([10, 20]))
    }


    @Test
    func expressibleByConfigIntArrayParseReturnsContentForFormattedInput() {
        let parse = ConfigVariableContent<[MockConfigIntValue]>.expressibleByConfigIntArray().parse
        let input = [1_234, 5_678].map { $0.formatted() }.joined(separator: "\n")
        #expect(parse?(input) == .intArray([1_234, 5_678]))
    }


    @Test
    func expressibleByConfigIntArrayParseReturnsNilForInvalidInput() {
        let parse = ConfigVariableContent<[MockConfigIntValue]>.expressibleByConfigIntArray().parse
        #expect(parse?("10\nnotAnInt") == nil)
    }


    @Test
    func jsonParseReturnsStringContentForStringRepresentation() {
        let parse = ConfigVariableContent<MockCodableValue>.json().parse
        #expect(parse?("{\"value\":\"hello\"}") == .string("{\"value\":\"hello\"}"))
    }


    @Test
    func jsonParseIsNilForDataRepresentation() {
        let parse = ConfigVariableContent<MockCodableValue>.json(representation: .data).parse
        #expect(parse == nil)
    }


    // MARK: - Validate

    @Test
    func primitiveValidateIsNil() {
        #expect(ConfigVariableContent<Bool>.bool.validate == nil)
        #expect(ConfigVariableContent<Int>.int.validate == nil)
        #expect(ConfigVariableContent<Float64>.float64.validate == nil)
        #expect(ConfigVariableContent<String>.string.validate == nil)
        #expect(ConfigVariableContent<[Bool]>.boolArray.validate == nil)
        #expect(ConfigVariableContent<[Int]>.intArray.validate == nil)
        #expect(ConfigVariableContent<[Float64]>.float64Array.validate == nil)
        #expect(ConfigVariableContent<[String]>.stringArray.validate == nil)
    }


    @Test
    func rawRepresentableStringValidateReturnsTrueForValidRawValue() {
        let validate = ConfigVariableContent<MockNonIterableStringEnum>.rawRepresentableString().validate
        #expect(validate?(.string("a")) == true)
    }


    @Test
    func rawRepresentableStringValidateReturnsFalseForInvalidRawValue() {
        let validate = ConfigVariableContent<MockNonIterableStringEnum>.rawRepresentableString().validate
        #expect(validate?(.string("invalid")) == false)
    }


    @Test
    func rawRepresentableStringValidateReturnsFalseForNonStringContent() {
        let validate = ConfigVariableContent<MockNonIterableStringEnum>.rawRepresentableString().validate
        #expect(validate?(.int(0)) == false)
    }


    @Test
    func rawRepresentableIntValidateReturnsTrueForValidRawValue() {
        let validate = ConfigVariableContent<MockNonIterableIntEnum>.rawRepresentableInt().validate
        #expect(validate?(.int(0)) == true)
    }


    @Test
    func rawRepresentableIntValidateReturnsFalseForInvalidRawValue() {
        let validate = ConfigVariableContent<MockNonIterableIntEnum>.rawRepresentableInt().validate
        #expect(validate?(.int(999)) == false)
    }


    @Test
    func rawRepresentableIntValidateReturnsFalseForNonIntContent() {
        let validate = ConfigVariableContent<MockNonIterableIntEnum>.rawRepresentableInt().validate
        #expect(validate?(.string("0")) == false)
    }


    @Test
    func expressibleByConfigStringValidateReturnsTrueForValidString() {
        let validate = ConfigVariableContent<MockConfigStringValue>.expressibleByConfigString().validate
        #expect(validate?(.string("hello")) == true)
    }


    @Test
    func expressibleByConfigStringValidateReturnsFalseForNonStringContent() {
        let validate = ConfigVariableContent<MockConfigStringValue>.expressibleByConfigString().validate
        #expect(validate?(.int(0)) == false)
    }


    @Test
    func expressibleByConfigIntValidateReturnsTrueForValidInt() {
        let validate = ConfigVariableContent<MockConfigIntValue>.expressibleByConfigInt().validate
        #expect(validate?(.int(42)) == true)
    }


    @Test
    func expressibleByConfigIntValidateReturnsFalseForNonIntContent() {
        let validate = ConfigVariableContent<MockConfigIntValue>.expressibleByConfigInt().validate
        #expect(validate?(.string("42")) == false)
    }


    @Test
    func rawRepresentableStringArrayValidateReturnsTrueForValidElements() {
        let validate = ConfigVariableContent<[MockNonIterableStringEnum]>.rawRepresentableStringArray().validate
        #expect(validate?(.stringArray(["a", "b"])) == true)
    }


    @Test
    func rawRepresentableStringArrayValidateReturnsFalseForInvalidElement() {
        let validate = ConfigVariableContent<[MockNonIterableStringEnum]>.rawRepresentableStringArray().validate
        #expect(validate?(.stringArray(["a", "invalid"])) == false)
    }


    @Test
    func rawRepresentableStringArrayValidateReturnsFalseForNonStringArrayContent() {
        let validate = ConfigVariableContent<[MockNonIterableStringEnum]>.rawRepresentableStringArray().validate
        #expect(validate?(.string("a")) == false)
    }


    @Test
    func rawRepresentableIntArrayValidateReturnsTrueForValidElements() {
        let validate = ConfigVariableContent<[MockNonIterableIntEnum]>.rawRepresentableIntArray().validate
        #expect(validate?(.intArray([0, 1])) == true)
    }


    @Test
    func rawRepresentableIntArrayValidateReturnsFalseForInvalidElement() {
        let validate = ConfigVariableContent<[MockNonIterableIntEnum]>.rawRepresentableIntArray().validate
        #expect(validate?(.intArray([0, 999])) == false)
    }


    @Test
    func rawRepresentableIntArrayValidateReturnsFalseForNonIntArrayContent() {
        let validate = ConfigVariableContent<[MockNonIterableIntEnum]>.rawRepresentableIntArray().validate
        #expect(validate?(.int(0)) == false)
    }


    @Test
    func expressibleByConfigStringArrayValidateReturnsTrueForValidElements() {
        let validate = ConfigVariableContent<[MockConfigStringValue]>.expressibleByConfigStringArray().validate
        #expect(validate?(.stringArray(["x", "y"])) == true)
    }


    @Test
    func expressibleByConfigStringArrayValidateReturnsFalseForNonStringArrayContent() {
        let validate = ConfigVariableContent<[MockConfigStringValue]>.expressibleByConfigStringArray().validate
        #expect(validate?(.string("x")) == false)
    }


    @Test
    func expressibleByConfigIntArrayValidateReturnsTrueForValidElements() {
        let validate = ConfigVariableContent<[MockConfigIntValue]>.expressibleByConfigIntArray().validate
        #expect(validate?(.intArray([10, 20])) == true)
    }


    @Test
    func expressibleByConfigIntArrayValidateReturnsFalseForNonIntArrayContent() {
        let validate = ConfigVariableContent<[MockConfigIntValue]>.expressibleByConfigIntArray().validate
        #expect(validate?(.int(10)) == false)
    }


    @Test
    func codableValidateReturnsTrueForValidJSON() {
        let validate = ConfigVariableContent<MockCodableValue>.json().validate
        #expect(validate?(.string("{\"value\":\"hello\"}")) == true)
    }


    @Test
    func codableValidateReturnsFalseForInvalidJSON() {
        let validate = ConfigVariableContent<MockCodableValue>.json().validate
        #expect(validate?(.string("not json")) == false)
    }


    @Test
    func codableValidateReturnsFalseForNonStringContent() {
        let validate = ConfigVariableContent<MockCodableValue>.json().validate
        #expect(validate?(.int(0)) == false)
    }


    // MARK: - Updated Editor Controls

    @Test
    func boolArrayEditorControlIsTextEditor() {
        #expect(ConfigVariableContent<[Bool]>.boolArray.editorControl == .textEditor)
    }


    @Test
    func float64ArrayEditorControlIsTextEditor() {
        #expect(ConfigVariableContent<[Float64]>.float64Array.editorControl == .textEditor)
    }


    @Test
    func intArrayEditorControlIsTextEditor() {
        #expect(ConfigVariableContent<[Int]>.intArray.editorControl == .textEditor)
    }


    @Test
    func stringArrayEditorControlIsTextEditor() {
        #expect(ConfigVariableContent<[String]>.stringArray.editorControl == .textEditor)
    }


    @Test
    func rawRepresentableStringArrayEditorControlIsTextEditor() {
        let content = ConfigVariableContent<[MockNonIterableStringEnum]>.rawRepresentableStringArray()
        #expect(content.editorControl == .textEditor)
    }


    @Test
    func rawRepresentableIntArrayEditorControlIsTextEditor() {
        let content = ConfigVariableContent<[MockNonIterableIntEnum]>.rawRepresentableIntArray()
        #expect(content.editorControl == .textEditor)
    }


    @Test
    func expressibleByConfigStringArrayEditorControlIsTextEditor() {
        let content = ConfigVariableContent<[MockConfigStringValue]>.expressibleByConfigStringArray()
        #expect(content.editorControl == .textEditor)
    }


    @Test
    func expressibleByConfigIntArrayEditorControlIsTextEditor() {
        let content = ConfigVariableContent<[MockConfigIntValue]>.expressibleByConfigIntArray()
        #expect(content.editorControl == .textEditor)
    }


    @Test
    func jsonEditorControlIsTextEditorForStringRepresentation() {
        let content = ConfigVariableContent<MockCodableValue>.json()
        #expect(content.editorControl == .textEditor)
    }


    @Test
    func jsonEditorControlIsNilForDataRepresentation() {
        let content = ConfigVariableContent<MockCodableValue>.json(representation: .data)
        #expect(content.editorControl == nil)
    }


    @Test
    func rawRepresentableCaseIterableStringEditorControlIsPicker() {
        let content = ConfigVariableContent<MockStringEnum>.rawRepresentableCaseIterableString()
        #expect(content.editorControl?.pickerOptions != nil)
    }


    @Test
    func rawRepresentableCaseIterableIntEditorControlIsPicker() {
        let content = ConfigVariableContent<MockIntEnum>.rawRepresentableCaseIterableInt()
        #expect(content.editorControl?.pickerOptions != nil)
    }


    @Test
    func caseIterableStringPickerParseAndValidateAreNil() {
        let content = ConfigVariableContent<MockStringEnum>.rawRepresentableCaseIterableString()
        #expect(content.parse == nil)
        #expect(content.validate == nil)
    }


    @Test
    func caseIterableIntPickerParseAndValidateAreNil() {
        let content = ConfigVariableContent<MockIntEnum>.rawRepresentableCaseIterableInt()
        #expect(content.parse == nil)
        #expect(content.validate == nil)
    }
}
