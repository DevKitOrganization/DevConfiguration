# Editor UI Implementation Plan

This document breaks the Editor UI feature into incremental implementation slices. Each slice
is a self-contained unit of work that builds on the previous ones, is independently testable,
and results in a working (if incomplete) system.


## Slice 1: Metadata & Content Additions

Add the new metadata keys and editor control infrastructure to the existing types. No UI code.

### 1a: `displayName` Metadata Key

  - Define `DisplayNameMetadataKey` (private struct conforming to `ConfigVariableMetadataKey`)
  - Add `displayName: String?` computed property on `ConfigVariableMetadata`
  - Tests: set/get display name, verify display text, verify default is `nil`

### 1b: `requiresRelaunch` Metadata Key

  - Define `RequiresRelaunchMetadataKey` (private struct conforming to
    `ConfigVariableMetadataKey`)
  - Add `requiresRelaunch: Bool` computed property on `ConfigVariableMetadata`
  - Tests: set/get, verify display text, verify default is `false`

### 1c: `EditorControl` Enum

  - Define `EditorControl` enum with cases: `.toggle`, `.textField`, `.numberField`,
    `.decimalField`, `.none`
  - No conformances needed beyond `Sendable` (and `Hashable` for testing convenience)

### 1d: Editor Support on `ConfigVariableContent`

  - Add `editorControl: EditorControl` property to `ConfigVariableContent`
  - Add `parse: (@Sendable (String) -> ConfigContent?)?` property to `ConfigVariableContent`
  - Update all content factories to set these:
    - `.bool` → `.toggle`, parse: `{ Bool($0).map { .bool($0) } }`
    - `.string` → `.textField`, parse: `{ .string($0) }`
    - `.int` → `.numberField`, parse: `{ Int($0).map { .int($0) } }`
    - `.float64` → `.decimalField`, parse: `{ Double($0).map { .double($0) } }`
    - `.rawRepresentableString()` → `.textField`, parse: `{ .string($0) }`
    - `.rawRepresentableInt()` → `.numberField`, parse: `{ Int($0).map { .int($0) } }`
    - `.expressibleByConfigString()` → `.textField`, parse: `{ .string($0) }`
    - `.expressibleByConfigInt()` → `.numberField`, parse: `{ Int($0).map { .int($0) } }`
    - All array and codable variants → `.none`, parse: `nil`
  - Tests: verify each factory sets the correct editor control and parse behavior

### 1e: Editor Support on `RegisteredConfigVariable`

  - Add `editorControl: EditorControl` and `parse` closure to `RegisteredConfigVariable`
  - Update `ConfigVariableReader.register(_:)` to capture these from the content
  - Tests: verify registration captures editor control and parse


## Slice 2: EditorOverrideProvider

Build the `ConfigProvider` that stores and persists editor overrides.

### 2a: In-Memory Storage

  - Create `EditorOverrideProvider` conforming to `ConfigProvider`
  - `providerName` returns `"Editor"`
  - Internal storage: `[ConfigKey: ConfigContent]`
  - Implement `value(forKey:type:)` — returns the stored content if present and type-compatible
  - Implement `fetchValue(forKey:type:)` — same logic, async
  - Implement `watchValue(forKey:type:updatesHandler:)` — yields values when overrides change
  - Implement `snapshot()` — returns current state
  - Public methods: `setOverride(_:forKey:)`, `removeOverride(forKey:)`, `removeAllOverrides()`,
    `overrides` (current dictionary), `hasOverride(forKey:)`
  - Tests: full coverage of storage, retrieval, removal, type compatibility

### 2b: UserDefaults Persistence

  - Add `load()` method that reads overrides from `UserDefaults(suiteName:)`
  - Add `persist()` method that writes overrides to UserDefaults
  - Add `clearPersistence()` method that removes the key from UserDefaults
  - Storage format: `[String: Data]` where values are JSON-encoded `ConfigContent`
  - `load()` is called on init; `persist()` is called externally after save
  - Tests: verify round-trip persistence, verify load on init, verify clear

### 2c: Integration with ConfigVariableReader

  - Add `isEditorEnabled: Bool` parameter to both `ConfigVariableReader` inits (default
    `false`)
  - When enabled, create `EditorOverrideProvider`, call `load()`, prepend to providers
  - Store reference to the provider as an optional internal property
  - Tests: verify provider is prepended when enabled, absent when disabled, overrides take
    precedence


## Slice 3: EditorDocument

Build the working copy model with undo/redo support.

### 3a: Core Working Copy

  - Create `EditorDocument` (or `ConfigEditorDocument`)
  - Initialized with `EditorOverrideProvider`'s current committed overrides
  - Tracks working copy as `[ConfigKey: ConfigContent]` (the full desired override state)
  - Methods:
    - `setOverride(_:forKey:)` — sets an override in the working copy
    - `removeOverride(forKey:)` — removes an override from the working copy
    - `removeAllOverrides()` — clears all overrides in the working copy
    - `override(forKey:) -> ConfigContent?` — returns the working copy's override
    - `hasOverride(forKey:) -> Bool`
    - `isDirty: Bool` — whether working copy differs from committed state
    - `changedKeys: Set<ConfigKey>` — keys that differ from committed state
  - Tests: full coverage of working copy operations and dirty tracking

### 3b: Save & Commit

  - `save()` method:
    - Computes delta (changed keys only)
    - Updates `EditorOverrideProvider` with the working copy state
    - Calls `persist()` on the provider
    - Updates the committed baseline to match the working copy
    - Returns the changed keys as a `Set<ConfigKey>`
  - The view model layer maps these keys to `RegisteredConfigVariable` values for the
    `onSave` closure
  - Tests: verify delta computation, provider update, persistence, baseline reset

### 3c: Undo/Redo Integration

  - `EditorDocument` accepts an `UndoManager?`
  - Each mutation method registers an undo action before applying the change
  - `removeAllOverrides()` registers a single undo action that restores the full prior state
  - Tests: verify undo/redo for set, remove, and clear-all operations


## Slice 4: View Model Layer

Build the view model protocols and concrete implementations. All testable without SwiftUI.

### 4a: Variable List View Model

  - **Protocol** `ConfigVariableListViewModeling` (outside `#if canImport(SwiftUI)`):
    - `var variables: [VariableListItem] { get }` — filtered/sorted list
    - `var searchText: String { get set }`
    - `func save() -> [RegisteredConfigVariable]`
    - `func cancel()`
    - `var isDirty: Bool { get }`
    - `func clearAllOverrides()`
    - `func undo()` / `func redo()`
    - `var canUndo: Bool { get }` / `var canRedo: Bool { get }`
    - Associated type for detail view model
  - **`VariableListItem`**: key, display name (defaults to key if not set), current value
    (as string), provider name, provider color index, has override (bool), editor control
  - **Concrete `ConfigVariableListViewModel`** (inside `#if canImport(SwiftUI)`):
    - `@Observable`, owns the `EditorDocument`
    - Queries each provider for current values to determine which provider is responsible
    - Sorts by display name (falling back to key)
    - Filters by search text across name, key, value, metadata
  - Tests: sorting, filtering, save/cancel, dirty tracking, undo/redo delegation

### 4b: Variable Detail View Model

  - **Protocol** `ConfigVariableDetailViewModeling` (outside `#if canImport(SwiftUI)`):
    - `var key: ConfigKey { get }`
    - `var displayName: String { get }`
    - `var metadata: [ConfigVariableMetadata.DisplayText] { get }`
    - `var providerValues: [ProviderValue] { get }` — value from each provider
    - `var isOverrideEnabled: Bool { get set }`
    - `var overrideText: String { get set }` — for text-based editors
    - `var overrideBool: Bool { get set }` — for toggle
    - `var editorControl: EditorControl { get }`
    - `var isSecretRevealed: Bool { get set }` — tap-to-reveal state
  - **`ProviderValue`**: provider name, color index, raw value string, is compatible (bool)
  - **Concrete `ConfigVariableDetailViewModel`**:
    - Reads from providers via `value(forKey:type:)` on each
    - Determines compatibility by checking if the `ConfigContent` case matches expected type
    - Override toggle delegates to `EditorDocument.setOverride` / `removeOverride`
    - Text/number changes parse via the stored `parse` closure and update the document
  - Tests: provider value display, compatibility detection, override enable/disable, parse
    validation, secret reveal toggle


## Slice 5: SwiftUI Views

Build the views. All inside `#if canImport(SwiftUI)`.

### 5a: Supporting Views

  - **`ProviderCapsuleView`** — colored rounded rect with provider name text
  - **Provider color assignment** — static function mapping provider index to system color;
    editor override provider always returns `.orange`

### 5b: ConfigVariableListView (List)

  - Generic on `ViewModel: ConfigVariableListViewModeling`
  - `NavigationStack` with `List`
  - Search bar via `.searchable` modifier
  - Each row: display name, key, value, provider capsule
  - Tap row → push `ConfigVariableDetailView`
  - Toolbar: Cancel (leading), Save (trailing), overflow menu with Undo, Redo, and Clear
    Editor Overrides
  - Cancel shows alert if dirty
  - Clear Editor Overrides shows confirmation alert

### 5c: ConfigVariableDetailView

  - Generic on `ViewModel: ConfigVariableDetailViewModeling`
  - Sections: Header, Override, Values, Metadata
  - Override section:
    - "Enable Override" toggle
    - When enabled, shows editor control based on `editorControl`
    - Toggle for `.toggle`
    - `TextField` for `.textField` / `.numberField` / `.decimalField` with appropriate
      keyboard types
  - Provider values section:
    - Each provider's value with capsule
    - Strikethrough for incompatible values
    - Tap-to-reveal for secret values
  - Metadata section: list of key-value pairs from `displayTextEntries`

### 5d: Public Entry Point

  - `ConfigVariableEditor` — a public `View` struct (inside `#if canImport(SwiftUI)`)
  - Initialized with a `ConfigVariableReader` and an
    `onSave: ([RegisteredConfigVariable]) -> Void` closure
  - Creates the list view model internally and wraps the list view
  - Asserts that `isEditorEnabled` is true on the reader

### 5e: View Tests

Tests use **Swift Snapshot Testing** for visual regression and **ViewInspector** for
structural and behavioral verification. Views are generic on their view model protocols, so
tests inject mock view models.

  - **Snapshot tests** (visual regression):
    - List view: empty state, populated list, list with overrides, list with search active
    - Detail view: read-only variable, variable with override enabled (each editor control
      type), secret value redacted vs revealed, incompatible provider values with
      strikethrough
    - Provider capsule: each provider color, editor override provider color
    - Snapshots captured for both iOS and Mac to verify cross-platform layout
  - **ViewInspector tests** (structural/behavioral):
    - List view: verify rows render correct display name, key, value, and provider capsule;
      verify search filters rows; verify cancel alert appears when dirty; verify save calls
      view model; verify overflow menu contains undo, redo, and clear actions
    - Detail view: verify sections are present; verify "Enable Override" toggle shows/hides
      editor control; verify toggle control binds to `overrideBool`; verify text field
      controls bind to `overrideText`; verify tap-to-reveal toggles `isSecretRevealed`;
      verify incompatible values have strikethrough


## Slice 6: Polish & Integration

### 6a: Accessibility

  - Ensure all interactive elements have accessibility labels
  - Provider capsules should be distinguishable without color (include provider name text)
  - Override controls should announce state changes

### 6b: Mac Compatibility

  - Verify layout works on macOS (wider layout, no `.numberPad` keyboard)
  - Adjust text fields to use appropriate styling per platform

### 6c: Documentation

  - DocC documentation for all public types and methods
  - Usage guide with code examples
  - Add to existing architecture documentation


## Dependencies Between Slices

    Slice 1 (Metadata & Content)
        │
        ├──▶ Slice 2 (EditorOverrideProvider)
        │        │
        │        └──▶ Slice 3 (EditorDocument)
        │                 │
        │                 └──▶ Slice 4 (View Models)
        │                          │
        │                          └──▶ Slice 5 (Views)
        │                                   │
        │                                   └──▶ Slice 6 (Polish)
        │
        └──▶ Slice 4 can begin protocol design in parallel with Slices 2–3

Slices 1 and 2a–2b can proceed in parallel. Slice 4's protocol definitions can be drafted
alongside Slices 2–3, with concrete implementations depending on those slices.


## New Package Dependencies

Slice 5e requires two new test dependencies in `Package.swift`:

  - **swift-snapshot-testing** (Point-Free): visual regression tests for views
  - **ViewInspector**: structural and behavioral verification of SwiftUI view hierarchies

These are added only to the test target.
