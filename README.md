# DevConfiguration

DevConfiguration is a type-safe configuration wrapper built on Apple's swift-configuration library.
It provides structured configuration management with telemetry, extensible metadata, and a variable
management interface.

DevConfiguration is fully documented and tested and supports iOS 26+, macOS 26+, tvOS 26+, visionOS
26+, and watchOS 26+.

View our [changelog](CHANGELOG.md) to see what’s new.


## Development Requirements

DevConfiguration requires a Swift 6.2 toolchain to build. We only test on Apple platforms. We follow
the [Swift API Design Guidelines][SwiftAPIDesignGuidelines]. We take pride in the fact that our
public interfaces are fully documented and tested. We aim for overall test coverage over 99%.

[SwiftAPIDesignGuidelines]: https://swift.org/documentation/api-design-guidelines/

### Development Setup

To set up the development environment:

  1. Run `Scripts/install-git-hooks` to install pre-commit hooks that automatically check
     code formatting.
  2. Use `Scripts/lint` to manually check code formatting at any time.
  3. Use `Scripts/format` to automatically format code.

### Code Generation with GYB

Some source files are generated using [GYB][GYB] (Generate Your Boilerplate) to reduce
repetitive boilerplate. Generated `.swift` files are checked in so that contributors don't
need to run GYB unless they modify a template. To regenerate after changing a `.gyb` template
or `Scripts/gyb/gyb_utils.py`:

    Scripts/generate-gyb

Do not edit generated files directly — edit the `.gyb` template instead. See
[Documentation/CodeGeneration.md](Documentation/CodeGeneration.md) for details on template
syntax, type definitions, and workflows.

[GYB]: https://github.com/apple/swift/blob/main/utils/gyb.py


## Bugs and Feature Requests

Find a bug? Want a new feature? Create a GitHub issue and we’ll take a look.


## License

All code is licensed under the MIT license. Do with it as you will.
