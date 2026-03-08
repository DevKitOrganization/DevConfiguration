# Editor UI Architecture Plan


## Overview

The Editor UI is a SwiftUI-based interface that allows users to inspect and override the values
of registered configuration variables in a `ConfigVariableReader`. It operates as a "document"
— changes are staged in a working copy, committed on save, and persisted across app launches
via a `ConfigProvider` backed by UserDefaults.

The editor is opt-in: `ConfigVariableReader` accepts an `isEditorEnabled` flag at init. When
enabled, an internal override provider is prepended to the reader's provider list, taking
precedence over all other providers.


## Module Structure

All editor code lives in the `DevConfiguration` target, guarded by `#if canImport(SwiftUI)`.

  - **View model protocols** (`*ViewModeling`) live **outside** the `#if` block so they can be
    tested without SwiftUI.
  - **Views** (`*View`) and **concrete view models** (`*ViewModel`) live inside the `#if` block.
  - The full MVVM pattern is used: `*ViewModeling` protocol, generic `*View`, and `@Observable`
    `*ViewModel`.


## Key Types


### EditorOverrideProvider

A `ConfigProvider` implementation that stores override values in memory and persists them to
UserDefaults.

  - **Suite**: `devkit.DevConfiguration`
  - **Provider name**: `"Editor"`
  - Conforms to `ConfigProvider` (sync `value(forKey:type:)`, async `fetchValue`, `watchValue`)
  - On init, loads any previously persisted overrides from UserDefaults
  - On save, writes current overrides to UserDefaults
  - On clear, removes all overrides from both memory and UserDefaults (after save)
  - Prepended to the reader's `providers` array when `isEditorEnabled` is true
  - Always assigned a distinctive color (e.g., `.orange`) for the provider capsule


### EditorDocument

The working copy model that tracks staged overrides, enabling save, cancel, undo, and redo.

  - Initialized with the current committed overrides from `EditorOverrideProvider`
  - Tracks a dictionary of `[ConfigKey: ConfigContent?]` where:
    - A key with a `ConfigContent` value means "override this variable with this value"
    - A key with `nil` means "remove the override for this variable"
    - Absence of a key means "no change from committed state"
  - **Dirty tracking**: compares working copy against committed state to determine if there
    are unsaved changes
  - **Undo/redo**: integrates with `UndoManager`; each override change (set, remove, clear
    all) registers an undo action
  - **Save**: computes the delta of changed keys, commits to `EditorOverrideProvider`, calls
    the `onSave` closure with a collection of `SavedChange` values (each containing the key
    and the variable's full `RegisteredConfigVariable`, giving consumers access to all
    metadata including `requiresRelaunch`)
  - **Clear all overrides**: removes all overrides in the working copy (undoable, requires
    save to take effect)


### ConfigVariableReader Changes

  - New `isEditorEnabled: Bool` parameter on init (immutable, defaults to `false`)
  - When enabled, creates an `EditorOverrideProvider` and prepends it to the providers list
  - Stores a reference to the `EditorOverrideProvider` for use by the editor UI
  - Exposes a method or property to get the editor view (exact API TBD — see
    [Public API Surface](#public-api-surface))


### ConfigVariableContent Additions

New properties to support editing:

  - **`editorControl: EditorControl`** — describes which UI control to show:
    - `.toggle` — for `Bool`
    - `.textField` — for `String`
    - `.numberField` — for `Int`
    - `.decimalField` — for `Float64`
    - `.none` — for types that don't support editing (bytes, arrays, codable)
  - **`parse: @Sendable (String) -> ConfigContent?`** — for text-based editors, parses raw user
    input into a `ConfigContent` value; `nil` if input is invalid

Content factories set these automatically:

  - `.bool` → `.toggle`, parse: `Bool("true"/"false")` → `.bool(_)`
  - `.string` → `.textField`, parse: identity → `.string(_)`
  - `.int` → `.numberField`, parse: `Int(_)` → `.int(_)`
  - `.float64` → `.decimalField`, parse: `Double(_)` → `.double(_)`
  - `.rawRepresentableString()` → `.textField`, parse: identity → `.string(_)`
  - `.rawRepresentableInt()` → `.numberField`, parse: `Int(_)` → `.int(_)`
  - All others → `.none`, parse: `nil`

These fields are stored on `RegisteredConfigVariable` at registration time.


### EditorControl

A struct with a private backing enum, allowing new control types to be added in the future
without breaking existing consumers.

    public struct EditorControl: Hashable, Sendable {
        private enum Kind: Hashable, Sendable {
            case toggle
            case textField
            case numberField
            case decimalField
            case none
        }

        private let kind: Kind

        public static var toggle: EditorControl { .init(kind: .toggle) }
        public static var textField: EditorControl { .init(kind: .textField) }
        public static var numberField: EditorControl { .init(kind: .numberField) }
        public static var decimalField: EditorControl { .init(kind: .decimalField) }
        public static var none: EditorControl { .init(kind: .none) }
    }


### ConfigVariableMetadata Additions

Two new metadata keys:

  - **`displayName: String?`** — a human-readable label for the variable, shown in the list and
    detail views. When `nil`, the variable's key is used as the display text.
  - **`requiresRelaunch: Bool`** — indicates that changes to this variable don't take effect
    until the app is relaunched. The editor does not act on this directly; it's provided to the
    `onSave` closure's changed keys so the consumer can prompt as appropriate.


## Views


### ConfigVariableEditorView (List View)

The top-level editor view showing all registered variables.

**Layout:**

  - **Toolbar**: Cancel button (leading), title ("Configuration Editor"), Save button
    (trailing), overflow menu (`...`) containing Undo, Redo, and Clear Editor Overrides
  - **Search bar**: filters variables by display name, key, current value, and metadata
  - **List**: one row per registered variable, sorted by display name (falling back to key)

**List row contents:**

  - Display name and key (both always shown; if no display name is set, the key is used as
    the display name, so it appears twice)
  - Current value (from working copy state — override if set, otherwise resolved value)
  - Provider capsule — colored rounded rect with the provider name; color is deterministic
    based on provider index (editor override provider always gets its own color)

**Actions:**

  - Tap row → navigates to detail view
  - Cancel → if dirty, shows "Discard Changes?" alert; otherwise dismisses
  - Save → commits working copy, calls `onSave` with changed variables, dismisses
  - Toolbar overflow menu (`...`): Undo, Redo, and Clear Editor Overrides
  - Clear Editor Overrides → shows confirmation alert, then clears all overrides in working
    copy (undoable, still requires save)


### ConfigVariableDetailView

The detail view for a single variable.

**Layout (sections):**

  - **Header**: display name, key
  - **Current Value**: the resolved value with its provider capsule
  - **Override section**:
    - "Enable Override" toggle
    - When enabled, shows the appropriate editor control based on `EditorControl`
    - Changes register with `UndoManager`
  - **Provider Values**: value from each provider, each with its provider capsule
    - Incompatible values (wrong `ConfigContent` case for the variable's type) shown with
      strikethrough
    - Secret values redacted by default with tap-to-reveal (detail view only)
  - **Metadata**: all metadata entries from `displayTextEntries`

**Editor controls by type:**

  - `.toggle` — `Toggle` bound to the override value
  - `.textField` — `TextField` (strings are treated as single-line; multiline support can be
    added later if a use case arises or a new `EditorControl` type is introduced)
  - `.numberField` — `TextField` with `.numberPad` keyboard, rejects fractional input
  - `.decimalField` — `TextField` with `.decimalPad` keyboard
  - `.none` — no override section (read-only)


## Provider Colors

Each provider is assigned a deterministic color from a fixed palette of SwiftUI system colors.
The assignment is based on the provider's index in the reader's `providers` array:

    private static let providerColors: [Color] = [
        .blue, .green, .purple, .pink, .teal, .indigo, .mint, .cyan, .brown, .gray
    ]

The editor override provider always uses `.orange`, regardless of index. If there are more
providers than colors, colors wrap around.


## Provider Value Display

To show the value from each provider in the detail view, the editor queries each provider
individually using `value(forKey:type:)`. The result is displayed as:

  - The raw `ConfigContent` value formatted as a string
  - A colored provider capsule with the provider's name
  - If the `ConfigContent` case doesn't match the variable's expected type (e.g.,
    `.string("hello")` for a `Bool` variable), the value text is shown with strikethrough


## Undo/Redo

The editor uses SwiftUI's `UndoManager`, scoped to the editor session.

  - Each override change (enable, modify value, disable, clear all) registers an undo action
  - Undo/redo actions are available in the toolbar overflow menu (`...`)
  - The undo stack is discarded when the editor is dismissed


## Persistence

The `EditorOverrideProvider` persists its committed overrides to UserDefaults:

  - **Suite name**: `devkit.DevConfiguration`
  - **Storage format**: `ConfigContent` is `Codable` (it's an enum with associated values that
    are all codable), so overrides are stored as a `[String: Data]` dictionary where keys are
    config key strings and values are JSON-encoded `ConfigContent`
  - **Load**: on init, reads from UserDefaults and populates in-memory storage
  - **Save**: on commit, writes the full override dictionary to UserDefaults
  - **Clear**: on clear + save, removes the key from UserDefaults


## Public API Surface

The minimal public API for consumers:

    // On ConfigVariableReader
    public init(
        providers: [any ConfigProvider],
        eventBus: EventBus,
        isEditorEnabled: Bool = false
    )

    // Public view (inside #if canImport(SwiftUI))
    public struct ConfigVariableEditor: View {
        public init(
            reader: ConfigVariableReader,
            onSave: @escaping ([RegisteredConfigVariable]) -> Void
        )
    }

`ConfigVariableEditor` is a public SwiftUI view that consumers initialize directly with a
`ConfigVariableReader` and an `onSave` closure. The consumer is responsible for presentation
(sheet, full-screen cover, navigation push, etc.). The `onSave` closure receives an array of
`RegisteredConfigVariable` values for variables whose overrides changed, giving the consumer
access to all metadata (including `requiresRelaunch`) to decide on post-save behavior.


## Config Variable Issues (Future Integration)

The editor is designed to accommodate a future `ConfigVariableIssueEvaluator` system:

  - **`ConfigVariableIssueEvaluator` protocol**: given a snapshot of providers, their values,
    and registered variables, returns an array of issues
  - **`ConfigVariableIssue`**: has a kind (identifying string), affected variable (key),
    severity (warning/error), and human-readable description
  - **Evaluators** are passed to `ConfigVariableReader` at init
  - **Editor integration**: issues would appear as warning/error indicators in the list view
    rows and detail view, with a filter for "Variables with Issues"
  - **Non-editor usage**: a public function on the reader evaluates all issues on demand, which
    can be used for config hygiene checks in code

To prepare for this, the editor's list and detail views should be designed with space for
status indicators, and the filtering system should be extensible to support issue-based
filters.


## Design Decisions

  - **`#if canImport(SwiftUI)`** keeps everything in one target, avoiding a separate module
    and the public API surface it would require. View model protocols live outside the guard
    for testability.
  - **Working copy model** ensures the editor behaves like a document — changes are staged,
    can be undone, and only take effect on explicit save.
  - **`EditorControl` on `ConfigVariableContent`** lets each content type declare its editing
    capabilities at the type level, keeping the view layer free of type-switching logic.
  - **Deterministic provider colors** ensure a consistent visual identity across editor
    sessions without requiring providers to declare their own colors.
  - **`onSave` closure with changed `RegisteredConfigVariable` values** gives consumers full
    control over post-save behavior (relaunch prompts, analytics, etc.) without the editor
    needing to know about those concerns.
