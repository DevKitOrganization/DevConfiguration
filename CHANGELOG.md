# DevConfiguration Changelog


## 1.0.0: TBD

Description forthcoming.


## 0.12.0: TBD

This release contains **breaking changes** to the configuration variable editor’s custom content API.

 - `ConfigVariableEditor` no longer takes a `customSectionTitle` parameter. Instead, the `customContent` view
   builder is responsible for providing its own `Section` views (or other list content).
 - The `customSection` view builder parameter has been renamed to `customContent`.

If you previously presented the editor with a custom section title and content, move the section title into a
`Section` view inside `customContent`.


## 0.11.0: April 13, 2026

This release adds a confirm keyboard button on the variable detail screen so that users who edit numeric types can
actually commit the edit.


## 0.10.1: April 5, 2026

This release only contains small fixes in the project’s DocC documentation.


## 0.10.0: March 30, 2026

This is a tiny release that simply exports Configuration so that consumers don’t have to import both
DevConfiguration and Configuration.


## 0.9.0: March 29, 2026

This release makes the following changes:

 - `ConfigVariableEditor` now takes an optional `dismiss` closure instead of an `onSave` closure. This closure takes
   an array of modified variables just like `onSave`. However, if the `dismiss` closure is provided, it is the
   caller’s responsibility to dismiss the editor. If no closure is provided, the editor will use the environment’s
   dismiss action.
 - The `requiresRelaunch` config variable metadata key has been removed. In general, consumers should try to
   respond to variable changes at runtime. If this is not possible, you can create your own similar metadata key.


## 0.8.1: March 19, 2026

This is a small release that updates to DevFoundation 1.8.1 and makes `RegisteredConfigVariable`’s metadata
subscript public.


## 0.8.0: March 17, 2026

This is a small release that sorts metadata keys on the variable detail view of the editor.


## 0.7.0: March 17, 2026

This release adds the `isEditable` metadata value to config variables. When `false`, a config variable will not be
editable in the Config Variable Editor. `true` by default.


## 0.6.0: March 11, 2026

This release enhances the editor UI to show pickers for `CaseIterable` integers and strings, allow editing arrays
and JSON payloads in text editors, and handle formatting better for scalar types.


## 0.5.0: March 10, 2026

This release adds the ability for consumers to add a custom section to the config variable editor.


## 0.4.1: March 10, 2026

This release fixes a bug in which editor overrides were read from one UserDefaults instance, but saved to another.


## 0.4.0: March 10, 2026

This release adds a configuration editor written in SwiftUI. The editor allows consumers to view registered variable
values in a list, see the values of a variables across all the different providers, override values for development
and testing, and view variable metadata values.

The UI has only meaningfully been tested on iOS. It has not been accessibility tested.


## 0.3.0: March 10, 2026

This is a small release that updates `ConfigVariableReader` from a struct to a class to make variable registration
easier for consumers.


## 0.2.0: March 10, 2026

Adds the ability to register variables with `ConfigVariableReader`. This functionality is not yet used, but sets up
the public interface for consumers.


## 0.1.0: March 10, 2026

Initial version of DevConfiguration with the ability to read variables, with scalar, array, `RawRepresentable`, and
`Codable` types. Also emits access telemetry on the event bus.
