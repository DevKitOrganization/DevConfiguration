# VariablePrivacy Test Plan

Created by Duncan Lewis, 2026-01-07

## VariablePrivacy

### isPrivate
- .auto returns false
- .private returns true
- .public returns false

### isPrivateForSensitiveTypes
- .auto returns true
- .private returns true
- .public returns false
