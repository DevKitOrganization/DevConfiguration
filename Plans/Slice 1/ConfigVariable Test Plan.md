# ConfigVariable Test Plan

Created by Duncan Lewis, 2026-01-07

- `ConfigVariable<Value>`
  - init (w/ string)
    - init converts key string to ConfigKey
    - init stores parameters correctly (w/ each supported fallback value - 4 + 4)
    - init uses `.auto` privacy when not specified
    - init stores explicit privacy parameter
  - init (w/ config key)
    - init stores parameters correctly (w/ each supported fallback value - 4 + 4)
    - init uses `.auto` privacy when not specified
    - init stores explicit privacy parameter