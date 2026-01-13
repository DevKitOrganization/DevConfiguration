//
//  StructuredConfigReading.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 1/7/2026.
//

/// Provides typed access to `ConfigVariable` parameters.
///
/// This protocol defines the contract for resolving configuration variables
/// with compile-time type safety. Implementations handle provider lookups,
/// error handling, and fallback values automatically.
///
/// Values are always returned (never nil or thrown) - if resolution fails,
/// the variable's fallback value is used.
public protocol StructuredConfigReading {
    // MARK: - Primitive Types

    /// Gets the value for the specified `ConfigVariable<Bool>`.
    ///
    /// - Parameter variable: The variable to get a boolean value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    func value(for variable: ConfigVariable<Bool>) -> Bool

    /// Gets the value for the specified `ConfigVariable<String>`.
    ///
    /// - Parameter variable: The variable to get a string value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    func value(for variable: ConfigVariable<String>) -> String

    /// Gets the value for the specified `ConfigVariable<Int>`.
    ///
    /// - Parameter variable: The variable to get an integer value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    func value(for variable: ConfigVariable<Int>) -> Int

    /// Gets the value for the specified `ConfigVariable<Float64>`.
    ///
    /// - Parameter variable: The variable to get a float64 value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    func value(for variable: ConfigVariable<Float64>) -> Float64


    // MARK: - Array Types

    /// Gets the value for the specified `ConfigVariable<[Bool]>`.
    ///
    /// - Parameter variable: The variable to get a boolean array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    func value(for variable: ConfigVariable<[Bool]>) -> [Bool]

    /// Gets the value for the specified `ConfigVariable<[String]>`.
    ///
    /// - Parameter variable: The variable to get a string array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    func value(for variable: ConfigVariable<[String]>) -> [String]

    /// Gets the value for the specified `ConfigVariable<[Int]>`.
    ///
    /// - Parameter variable: The variable to get an integer array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    func value(for variable: ConfigVariable<[Int]>) -> [Int]

    /// Gets the value for the specified `ConfigVariable<[Float64]>`.
    ///
    /// - Parameter variable: The variable to get a float64 array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    func value(for variable: ConfigVariable<[Float64]>) -> [Float64]


    // MARK: - Subscript Access

    /// Gets the value for the specified `ConfigVariable<Bool>`.
    ///
    /// - Parameter variable: The variable to get a boolean value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    subscript(variable: ConfigVariable<Bool>) -> Bool { get }

    /// Gets the value for the specified `ConfigVariable<String>`.
    ///
    /// - Parameter variable: The variable to get a string value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    subscript(variable: ConfigVariable<String>) -> String { get }

    /// Gets the value for the specified `ConfigVariable<Int>`.
    ///
    /// - Parameter variable: The variable to get an integer value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    subscript(variable: ConfigVariable<Int>) -> Int { get }

    /// Gets the value for the specified `ConfigVariable<Float64>`.
    ///
    /// - Parameter variable: The variable to get a float64 value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    subscript(variable: ConfigVariable<Float64>) -> Float64 { get }

    /// Gets the value for the specified `ConfigVariable<[Bool]>`.
    ///
    /// - Parameter variable: The variable to get a boolean array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    subscript(variable: ConfigVariable<[Bool]>) -> [Bool] { get }

    /// Gets the value for the specified `ConfigVariable<[String]>`.
    ///
    /// - Parameter variable: The variable to get a string array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    subscript(variable: ConfigVariable<[String]>) -> [String] { get }

    /// Gets the value for the specified `ConfigVariable<[Int]>`.
    ///
    /// - Parameter variable: The variable to get an integer array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    subscript(variable: ConfigVariable<[Int]>) -> [Int] { get }

    /// Gets the value for the specified `ConfigVariable<[Float64]>`.
    ///
    /// - Parameter variable: The variable to get a float64 array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    subscript(variable: ConfigVariable<[Float64]>) -> [Float64] { get }
}


extension StructuredConfigReading {
    // MARK: - Default Subscript Implementations

    /// Gets the value for the specified `ConfigVariable<Bool>`.
    ///
    /// - Parameter variable: The variable to get a boolean value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public subscript(variable: ConfigVariable<Bool>) -> Bool {
        value(for: variable)
    }

    /// Gets the value for the specified `ConfigVariable<String>`.
    ///
    /// - Parameter variable: The variable to get a string value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public subscript(variable: ConfigVariable<String>) -> String {
        value(for: variable)
    }

    /// Gets the value for the specified `ConfigVariable<Int>`.
    ///
    /// - Parameter variable: The variable to get an integer value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public subscript(variable: ConfigVariable<Int>) -> Int {
        value(for: variable)
    }

    /// Gets the value for the specified `ConfigVariable<Float64>`.
    ///
    /// - Parameter variable: The variable to get a float64 value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public subscript(variable: ConfigVariable<Float64>) -> Float64 {
        value(for: variable)
    }

    /// Gets the value for the specified `ConfigVariable<[Bool]>`.
    ///
    /// - Parameter variable: The variable to get a boolean array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public subscript(variable: ConfigVariable<[Bool]>) -> [Bool] {
        value(for: variable)
    }

    /// Gets the value for the specified `ConfigVariable<[String]>`.
    ///
    /// - Parameter variable: The variable to get a string array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public subscript(variable: ConfigVariable<[String]>) -> [String] {
        value(for: variable)
    }

    /// Gets the value for the specified `ConfigVariable<[Int]>`.
    ///
    /// - Parameter variable: The variable to get an integer array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public subscript(variable: ConfigVariable<[Int]>) -> [Int] {
        value(for: variable)
    }

    /// Gets the value for the specified `ConfigVariable<[Float64]>`.
    ///
    /// - Parameter variable: The variable to get a float64 array value for.
    /// - Returns: The configuration value of the variable, or the fallback if resolution fails.
    public subscript(variable: ConfigVariable<[Float64]>) -> [Float64] {
        value(for: variable)
    }
}
