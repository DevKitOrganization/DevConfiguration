//
//  ConfigSnapshot+ConfigContent.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/9/2026.
//

import Configuration

extension ConfigSnapshot {
    /// Returns the ``ConfigContent`` for the given key, regardless of its type.
    ///
    /// This method first tries the preferred type, then probes the snapshot with all other configuration types to find
    /// a value. It is intended for editor use where we need to discover a provider's value without knowing its type in
    /// advance.
    ///
    /// - Parameters:
    ///   - key: The configuration key to look up.
    ///   - preferredType: The expected configuration type to try first.
    /// - Returns: The content value, or `nil` if the snapshot has no value for the key.
    func configContent(forKey key: ConfigKey, preferredType: ConfigType) -> ConfigContent? {
        let absoluteKey = AbsoluteConfigKey(key)

        // Try the preferred type first
        if let result = try? value(forKey: absoluteKey, type: preferredType), let configValue = result.value {
            return configValue.content
        }

        // Fall back to all other types
        let allTypes: [ConfigType] = [
            .bool, .int, .double, .string, .bytes,
            .boolArray, .intArray, .doubleArray, .stringArray, .byteChunkArray,
        ]

        for type in allTypes where type != preferredType {
            if let result = try? value(forKey: absoluteKey, type: type), let configValue = result.value {
                return configValue.content
            }
        }

        return nil
    }
}
