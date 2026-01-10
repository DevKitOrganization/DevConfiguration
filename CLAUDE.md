# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this
repository.


## Development Commands

### Building and Testing

  - **Build**: `swift build`
  - **Test all**: `swift test`
  - **Test specific target**: `swift test --filter DevConfigurationTests`
  - **Test with coverage**: Use Xcode test plans in `Build Support/Test Plans/` (AllTests.xctestplan
    for all tests)

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
  - Requires Xcode 16.0.1 and macOS 16 runners


## Architecture Overview

DevConfiguration is a type-safe configuration wrapper built on Apple's swift-configuration library.
It provides structured configuration management with telemetry, caching, and extensible metadata.

### Key Documents

  - **Architecture Plan.md**: Complete architectural design and technical decisions
  - **Implementation Plan.md**: Phased implementation roadmap broken into 6 slices
  - **Documentation/TestingGuidelines.md**: Testing standards and patterns
  - **Documentation/TestMocks.md**: Mock creation and usage guidelines
  - **Documentation/DependencyInjection.md**: Dependency injection patterns
  - **Documentation/MarkdownStyleGuide.md**: Documentation formatting standards


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
  - Implementation follows phased approach in Implementation Plan.md