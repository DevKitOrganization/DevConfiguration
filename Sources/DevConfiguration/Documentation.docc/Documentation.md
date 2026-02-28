# ``DevConfiguration``

A type-safe wrapper around Swift Configuration with conveniences for type safety and app development. 


## Overview

DevConfiguration is a type-safe configuration wrapper built on Apple's Swift Configuration library. It provides 
configuration management with extensible metadata, a variable management UI, and access logging via the event bus. 


## Topics

### Reading Variables

- ``ConfigVariable``
- ``ConfigVariableReader``

### Variable Metadata

- ``ConfigVariableMetadata``
- ``ConfigVariableMetadataKey``
- ``ConfigVariableSecrecy``

### Access Reporting

- ``EventBusAccessReporter``
- ``ConfigVariableAccessSucceededEvent``
- ``ConfigVariableAccessFailedEvent``

### Supporting Types

- ``ConfigValueReadable``
