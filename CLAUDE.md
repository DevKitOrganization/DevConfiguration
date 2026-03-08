# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this
repository.


## Development Commands

### Building and Testing

  - **Build**: `xcodebuild build -scheme DevConfiguration -destination 'generic/platform=macOS'`
  - **Test all**: `xcodebuild test -scheme DevConfiguration -destination 'platform=macOS'`
  - **Test with coverage**: Use Xcode test plans in `Build Support/Test Plans/`
    (DevConfiguration.xctestplan)

### Code Quality

  - **Lint**: `Scripts/lint` (uses `swift format lint --recursive --strict`)
  - **Format**: `Scripts/format` 
  - **Setup git hooks**: `Scripts/install-git-hooks` (auto-formats on commit)

### GitHub Actions

The repository uses GitHub Actions for CI/CD with the workflow in
`.github/workflows/VerifyChanges.yaml`. The workflow:

  - Lints code on PRs using `swift format`
  - Builds and tests on macOS only (other platforms disabled due to GitHub Actions stability)
  - Generates code coverage reports using xccovPretty
  - Requires Xcode 26.0.1 and macOS 26 runners


## Architecture Overview

DevConfiguration is a type-safe configuration wrapper built on Apple's swift-configuration library.
It provides structured configuration management with access reporting via EventBus and extensible
metadata.

### Source Structure

  - **Sources/DevConfiguration/Core/**: `ConfigVariable`, `ConfigVariableReader`,
    `ConfigVariableContent`, `CodableValueRepresentation`, `RegisteredConfigVariable`,
    and `ConfigVariableSecrecy`
  - **Sources/DevConfiguration/Metadata/**: `ConfigVariableMetadata` and metadata key types
    (`DisplayNameMetadataKey`, `RequiresRelaunchMetadataKey`)
  - **Sources/DevConfiguration/Access Reporting/**: EventBus-based access and decoding events

### Key Documents

  - **Documentation/TestingGuidelines.md**: Testing standards and patterns
  - **Documentation/TestMocks.md**: Mock creation and usage guidelines
  - **Documentation/DependencyInjection.md**: Dependency injection patterns
  - **Documentation/MarkdownStyleGuide.md**: Documentation formatting standards
  - **Documentation/MVVMForSwiftUI.md**: MVVM architecture for SwiftUI
  - **Documentation/MVVMForSwiftUIBackground.md**: Background on MVVM design decisions


## Dependencies

External dependencies managed via Swift Package Manager:

  - **swift-configuration** (Apple): Core configuration provider system
  - **DevFoundation**: EventBus, utilities, networking
  - **DevTesting**: Stub-based testing framework


## Development Notes

  - Follows Swift API Design Guidelines
  - Uses Swift 6.2 with `ExistentialAny` and `MemberImportVisibility` features enabled
  - Minimum deployment targets: iOS, macOS, tvOS, visionOS, and watchOS 26
  - All public APIs must be documented and tested
  - Test coverage target: >99%