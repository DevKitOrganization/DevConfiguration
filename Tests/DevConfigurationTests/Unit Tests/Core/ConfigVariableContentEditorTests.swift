//
//  ConfigVariableContentEditorTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/7/2026.
//

import Configuration
import DevTesting
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
    func boolArrayEditorControlIsNone() {
        #expect(ConfigVariableContent<[Bool]>.boolArray.editorControl == .none)
    }


    @Test
    func float64EditorControlIsDecimalField() {
        #expect(ConfigVariableContent<Float64>.float64.editorControl == .decimalField)
    }


    @Test
    func float64ArrayEditorControlIsNone() {
        #expect(ConfigVariableContent<[Float64]>.float64Array.editorControl == .none)
    }


    @Test
    func intEditorControlIsNumberField() {
        #expect(ConfigVariableContent<Int>.int.editorControl == .numberField)
    }


    @Test
    func intArrayEditorControlIsNone() {
        #expect(ConfigVariableContent<[Int]>.intArray.editorControl == .none)
    }


    @Test
    func stringEditorControlIsTextField() {
        #expect(ConfigVariableContent<String>.string.editorControl == .textField)
    }


    @Test
    func stringArrayEditorControlIsNone() {
        #expect(ConfigVariableContent<[String]>.stringArray.editorControl == .none)
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
        let content = ConfigVariableContent<TestStringEnum>.rawRepresentableString()
        #expect(content.editorControl == .textField)
    }


    @Test
    func rawRepresentableStringArrayEditorControlIsNone() {
        let content = ConfigVariableContent<[TestStringEnum]>.rawRepresentableStringArray()
        #expect(content.editorControl == .none)
    }


    @Test
    func rawRepresentableIntEditorControlIsNumberField() {
        let content = ConfigVariableContent<TestIntEnum>.rawRepresentableInt()
        #expect(content.editorControl == .numberField)
    }


    @Test
    func rawRepresentableIntArrayEditorControlIsNone() {
        let content = ConfigVariableContent<[TestIntEnum]>.rawRepresentableIntArray()
        #expect(content.editorControl == .none)
    }


    @Test
    func expressibleByConfigStringEditorControlIsTextField() {
        let content = ConfigVariableContent<MockConfigStringValue>.expressibleByConfigString()
        #expect(content.editorControl == .textField)
    }


    @Test
    func expressibleByConfigStringArrayEditorControlIsNone() {
        let content = ConfigVariableContent<[MockConfigStringValue]>.expressibleByConfigStringArray()
        #expect(content.editorControl == .none)
    }


    @Test
    func expressibleByConfigIntEditorControlIsNumberField() {
        let content = ConfigVariableContent<MockConfigIntValue>.expressibleByConfigInt()
        #expect(content.editorControl == .numberField)
    }


    @Test
    func expressibleByConfigIntArrayEditorControlIsNone() {
        let content = ConfigVariableContent<[MockConfigIntValue]>.expressibleByConfigIntArray()
        #expect(content.editorControl == .none)
    }


    @Test
    func jsonEditorControlIsNone() {
        let content = ConfigVariableContent<TestCodable>.json()
        #expect(content.editorControl == .none)
    }


    @Test
    func propertyListEditorControlIsNone() {
        let content = ConfigVariableContent<TestCodable>.propertyList()
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
        let parse = ConfigVariableContent<TestStringEnum>.rawRepresentableString().parse
        let value = randomAlphanumericString()
        #expect(parse?(value) == .string(value))
    }


    @Test
    mutating func rawRepresentableIntParseReturnsIntContentForValidInput() {
        let parse = ConfigVariableContent<TestIntEnum>.rawRepresentableInt().parse
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
    func arrayAndByteContentParseIsNil() {
        #expect(ConfigVariableContent<[Bool]>.boolArray.parse == nil)
        #expect(ConfigVariableContent<[Float64]>.float64Array.parse == nil)
        #expect(ConfigVariableContent<[Int]>.intArray.parse == nil)
        #expect(ConfigVariableContent<[String]>.stringArray.parse == nil)
        #expect(ConfigVariableContent<[UInt8]>.bytes.parse == nil)
        #expect(ConfigVariableContent<[[UInt8]]>.byteChunkArray.parse == nil)
        #expect(ConfigVariableContent<[TestStringEnum]>.rawRepresentableStringArray().parse == nil)
        #expect(ConfigVariableContent<[TestIntEnum]>.rawRepresentableIntArray().parse == nil)
        #expect(ConfigVariableContent<[MockConfigStringValue]>.expressibleByConfigStringArray().parse == nil)
        #expect(ConfigVariableContent<[MockConfigIntValue]>.expressibleByConfigIntArray().parse == nil)
    }


    @Test
    func codableContentParseIsNil() {
        #expect(ConfigVariableContent<TestCodable>.json().parse == nil)
        #expect(ConfigVariableContent<TestCodable>.propertyList().parse == nil)
    }
}


// MARK: - Test Types

private enum TestStringEnum: String, Sendable {
    case a
    case b
}


private enum TestIntEnum: Int, Sendable {
    case a = 0
    case b = 1
}


private struct TestCodable: Codable, Sendable {
    let value: String
}
