//
//  ConfigVariableSecrecy.swift
//  DevConfiguration
//
//  Created by Duncan Lewis on 1/7/2026.
//

import Configuration

/// Controls whether a configuration variable's value is treated as secret.
///
/// Variable secrecy determines how values are handled in telemetry, logging, and other observability systems. Secret
/// values are redacted or obfuscated to prevent sensitive information from being exposed.
public enum ConfigVariableSecrecy: CaseIterable, Sendable {
    /// Treats `String`, `[String]`, and `String`-backed values as secret and all other types as public.
    ///
    /// This is the default secrecy level and provides sensible protection for most use cases.
    case auto

    /// Always treat the value as secret.
    ///
    /// Use this for sensitive data that should never be logged or exposed, regardless of type.
    case secret

    /// Never treat the value as secret.
    ///
    /// Use this when you explicitly want values to be visible in logs and telemetry, even if they are strings,
    /// string arrays, or string-backed.
    case `public`
}
