//
//  ContentViewModel.swift
//  ExampleApp
//
//  Created by Prachi Gauriar on 3/8/26.
//

import Configuration
import DevConfiguration
import DevFoundation
import Foundation

final class ContentViewModel {
    let configVariableReader: ConfigVariableReader
    let inMemoryProvider = MutableInMemoryProvider(initialValues: [:])
    let eventBus: EventBus = EventBus()

    let boolVariable = ConfigVariable(key: "dark_mode_enabled", defaultValue: false)
        .metadata(\.displayName, "Dark Mode Enabled")
    let float64Variable = ConfigVariable(key: "gravitationalConstant", defaultValue: 6.6743e-11)
        .metadata(\.displayName, "Newton’s Gravitational Constant")
    let intVariable = ConfigVariable(key: "configurationRefreshInterval", defaultValue: 1000)
        .metadata(\.displayName, "Configuration Refresh Interval (ms)")
    let stringVariable = ConfigVariable(key: "appName", defaultValue: "Example", secrecy: .public)
        .metadata(\.displayName, "App Name")

    let boolArrayVariable = ConfigVariable(key: "bool_array", defaultValue: [false, true, true, false])
        .metadata(\.displayName, "Bool Array Example")
    let float64ArrayVariable = ConfigVariable(key: "float64_array", defaultValue: [0, 1, 2.78182, 3.14159])
        .metadata(\.displayName, "Float Array Example")
    let intArrayVariable = ConfigVariable(key: "int_array", defaultValue: [1, 2, 4, 8, 16, 32])
        .metadata(\.displayName, "Int Array Example")
    let stringArrayVariable = ConfigVariable(
        key: "string_array",
        defaultValue: ["Thom", "Jonny", "Ed", "Colin", "Phil"],
        secrecy: .public
    ).metadata(\.displayName, "String Array Example")

    let jsonVariable = ConfigVariable(
        key: "complexConfig",
        defaultValue: ComplexConfiguration(field1: "a", field2: 1),
        content: .json(representation: .data),
        secrecy: .public
    ).metadata(\.displayName, "Complex Config")

    let intBackedVariable = ConfigVariable(key: "favoriteCardSuit", defaultValue: CardSuit.spades)
        .metadata(\.displayName, "Favorite Card Suit")

    let stringBackedVariable = ConfigVariable(key: "favoriteBeatle", defaultValue: Beatle.john)
        .metadata(\.displayName, "Favorite Beatle")


    init() {
        self.configVariableReader = ConfigVariableReader(
            namedProviders: [
                NamedConfigProvider(EnvironmentVariablesProvider(), displayName: "Environment"),
                NamedConfigProvider(inMemoryProvider, displayName: "In-Memory"),
            ],
            eventBus: eventBus,
            isEditorEnabled: true
        )

        configVariableReader.register(boolVariable)
        configVariableReader.register(boolArrayVariable)
        configVariableReader.register(float64Variable)
        configVariableReader.register(float64ArrayVariable)
        configVariableReader.register(intVariable)
        configVariableReader.register(intArrayVariable)
        configVariableReader.register(intBackedVariable)
        configVariableReader.register(stringVariable)
        configVariableReader.register(stringArrayVariable)
        configVariableReader.register(stringBackedVariable)
        configVariableReader.register(jsonVariable)
    }


    var variableValues: String {
        """
        boolVariable = \(configVariableReader[boolVariable])
        boolArrayVariable = \(configVariableReader[boolArrayVariable])
        float64Variable = \(configVariableReader[float64Variable])
        float64ArrayVariable = \(configVariableReader[float64ArrayVariable])
        intVariable = \(configVariableReader[intVariable])
        intArrayVariable = \(configVariableReader[intArrayVariable])
        intBackedVariable = \(configVariableReader[intBackedVariable])
        stringVariable = \(configVariableReader[stringVariable])
        stringArrayVariable = \(configVariableReader[stringArrayVariable])
        stringBackedVariable = \(configVariableReader[stringBackedVariable])
        jsonVariable = \(configVariableReader[jsonVariable])
        """
    }
}


struct ComplexConfiguration: Codable, Hashable, Sendable {
    let field1: String
    let field2: Int
}


enum Beatle: String, Codable, Hashable, Sendable {
    case john = "John"
    case paul = "Paul"
    case george = "George"
    case ringo = "Ringo"
}


enum CardSuit: Int, Codable, Hashable, Sendable {
    case spades
    case hearts
    case clubs
    case diamonds
}
