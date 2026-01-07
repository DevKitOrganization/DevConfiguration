# ConfigVariable Test Plan

Created by Duncan Lewis, 2026-01-07

- `ConfigVariable<Value>`
  - init (w/ string)
    - init converts key string to ConfigKey
  - init (w/ config key)
    - init stores parameters correctly (w/ each supported fallback value - 4 + 4)