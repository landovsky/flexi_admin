# Input Mode Current State

## Summary

`FlexiAdmin::Components::Resource::AutocompleteComponent` still supports `action: :input`, but its shipped behavior is intentionally narrower than the enhanced resource autocomplete work.

- `:input` remains a plain-text suggestion field.
- It still uses a `<textarea>` with the `expandable-field` controller.
- It does **not** select or store a resource ID.
- The production-safe rollback kept existing datalist search semantics in place.

## What Shipped

### Kept

- Enhanced autocomplete improvements for the main `autocomplete` flow, especially `:select` mode.
- Dummy app documentation/examples for input mode via a dedicated "Input Mode Examples" tab.
- Input-mode textarea height normalization so the resting height matches the standard single-line autocomplete fields while still expanding when content wraps.

### Intentionally Not Shipped

- Redefining datalist / `action: :input` filtering semantics to search only displayed field values.
- Input-mode demos that implied highlight, result-limit, empty-state, or other richer datalist behaviors that were not validated against production usage.
- Any change from `<textarea>` to `<input>` for `action: :input`.

## Current Semantics

### `:select`

- Searches records.
- Stores the selected resource ID in a hidden field.
- Supports the enhanced autocomplete options and documented select-mode behavior.

### `:show`

- Searches records.
- Displays clickable navigation results.

### `:input`

- Suggests plain-text values derived from the configured `fields`.
- Writes the selected text into the visible field only.
- Uses the legacy datalist backend behavior, which may search matching records more broadly than the displayed values.
- When disabled, renders legacy plain text by default.
- Can opt into a resource link for disabled rendering with `disabled_display: :link_if_resource` when a real resource is present.
- Should be documented and demonstrated conservatively until production usage is audited and a new contract is explicitly adopted.

## Dummy App Guidance

The dummy app's input-mode tab should demonstrate only what is true today:

- basic plain-text suggestions
- disabled with value
- disabled without value
- optional disabled resource link via explicit opt-in
- textarea autosize behavior

Avoid presenting value-level filtering, highlighted matches, empty-state semantics, or result-limit semantics as shipped `:input` capabilities unless the backend contract is deliberately changed and validated.
