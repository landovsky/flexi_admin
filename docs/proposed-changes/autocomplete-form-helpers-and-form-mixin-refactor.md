---
title: Autocomplete Form Helpers and Form Mixin Refactor
status: considering
date: 2026-03-18
---

# Autocomplete Form Helpers

## Context

`AutocompleteComponent` is the most complex form-adjacent component in flexi_admin. It serves three distinct use cases via the `action:` parameter:

1. **`:select`** — Model lookup/selector. Searches records, stores selected resource ID in a hidden input. Used in edit forms for `belongs_to` associations. Can prefill with an existing resource (disabled forms don't need a backend call).
2. **`:show`** — Search field on index pages. Input > search > display results > click to navigate to resource detail.
3. **`:input`** — Text autocomplete. Searches existing values, user picks or types freely. Uses `<textarea>` with expandable-field behavior.

Currently, all three are used via `custom_field` + direct `AutocompleteComponent.new(...)`:

```slim
= custom_field Resource::AutocompleteComponent.new(resource.inspection,
                                                   scope: 'inspections',
                                                   disabled: resource.persisted?), label: 'Kontrola'
```

Every other field type has a dedicated FormMixin helper (`text_field`, `select_field`, `date_field`, etc.) that handles label, validation errors, form-row layout, and disabled state automatically. Autocomplete is the only one that requires manual component instantiation.

## Problems to Solve

1. **Boilerplate** — 17 `custom_field Resource::AutocompleteComponent.new(...)` calls across 10 files in the host app. Each repeats scope resolution, field naming, and layout wiring.
2. **Inconsistency** — Autocomplete is the only field type without a FormMixin helper, breaking the pattern users have learned for every other field.
3. **Mixed concerns** — `AutocompleteComponent` bundles three fundamentally different interaction patterns (select a record, navigate to a record, autocomplete text) behind a single `action:` parameter. Parameters like `disabled_empty_custom_message` only apply to `:select`, `value:` only to `:input`.
4. **The `:show` mode** is used standalone on index pages (3 occurrences), outside of forms entirely — it doesn't belong in FormMixin.

## Options

### Option A: Helpers first, keep component as-is

Add FormMixin helpers that wrap `AutocompleteComponent`, forwarding parameters. The component itself stays unchanged.

**Helpers:**

```ruby
# :select mode — model lookup for belongs_to associations
def autocomplete_field(attr_name, scope:, label: nil, fields: [:title],
                       parent: nil, custom_scope: nil, **html_options)
  # infer resource from @resource.send(association)
  # infer name from attr_name
  # forward disabled from FormMixin
  component = AutocompleteComponent.new(associated_resource,
                                        scope:, action: :select, fields:,
                                        parent:, custom_scope:,
                                        name: attr_name, disabled:,
                                        **html_options)
  field_wrapper = render_field_wrapper(render(component), attr_name)
  inline ? field_wrapper : render_form_row(attr_name, field_wrapper, label:)
end

# :input mode — text autocomplete
def text_autocomplete_field(attr_name, scope:, label: nil, fields: [:title],
                            custom_scope: nil, **html_options)
  component = AutocompleteComponent.new(nil, scope:, action: :input,
                                        fields:, name: attr_name,
                                        custom_scope:,
                                        value: resource.try(attr_name),
                                        **html_options)
  field_wrapper = render_field_wrapper(render(component), attr_name)
  inline ? field_wrapper : render_form_row(attr_name, field_wrapper, label:)
end
```

**Usage becomes:**

```slim
/ Before
= custom_field Resource::AutocompleteComponent.new(resource.inspection,
                                                   scope: 'inspections',
                                                   disabled: resource.persisted?), label: 'Kontrola'

/ After
= autocomplete_field :inspection_id, scope: Inspection, label: 'Kontrola',
                      disabled: resource.persisted?
```

**Pros:**
- Zero changes to AutocompleteComponent — no risk to existing behavior
- Immediate reduction of boilerplate across host apps
- Helpers provide a stable API — if the component is later refactored, callers don't change
- Follows established FormMixin conventions (label, validation, disabled state)

**Cons:**
- Component internals remain tangled — helpers paper over the complexity
- Some parameter mapping gets awkward (e.g., `autocomplete_field` needs to resolve `resource.inspection` from `attr_name: :inspection_id`)

**Verdict:** Pragmatic, low-risk. Good as a stepping stone or as the final solution if component complexity stays manageable.

### Option B: Split component first, then add helpers

Break `AutocompleteComponent` into three focused components, then add thin helpers on top.

**Components:**

```
AutocompleteSelectComponent  — :select mode (model lookup, hidden input)
AutocompleteSearchComponent  — :show mode (index page search + navigate)
AutocompleteInputComponent   — :input mode (text autocomplete, textarea)
```

Each component gets only the parameters it needs. Shared behavior (Stimulus controller wiring, search path resolution, input group HTML) lives in a concern or base class.

**Pros:**
- Clean separation — each component has a focused API
- Parameters are self-documenting (no `disabled_empty_custom_message` on a text autocomplete)
- Easier to test each mode independently

**Cons:**
- Significant refactoring effort — template, component class, and all 20 call sites need updating
- Risk of regressions across three modes
- The shared behavior (80%+ of the code) needs to live somewhere — a base class or concern adds its own complexity
- The Stimulus controller and template branching is actually minimal today (`select?`, `data_list?`) — splitting may not reduce complexity much

**Verdict:** Theoretically clean, but the component's internal branching is small enough that the split creates more files without meaningfully reducing complexity. The JS controller would still need to handle all three modes (or also be split, which is even more churn).

### Option C: Helpers + lightweight component cleanup

Add helpers (like Option A), and simultaneously clean up the component interface without splitting it. Specifically:
- Make `scope:` accept both model classes and strings (normalize internally)
- Remove `target_controller:` — it was only needed for the old Proc-based scope; now `scope:` always provides the routing info
- Move `:show`-specific logic out if it diverges further (currently minimal)

**Pros:**
- Gets the helper benefits immediately
- Cleans up the component API without the risk of a full split
- Incremental — can always split later if complexity grows

**Cons:**
- Doesn't address the fundamental "three modes in one" design
- `target_controller:` removal requires checking all call sites

**Verdict:** Best balance of immediate value and reduced technical debt.

## Comparison

| Concern                     | A (helpers only) | B (split + helpers) | C (helpers + cleanup) |
|-----------------------------|:---:|:---:|:---:|
| Implementation effort       | Low | High | Medium |
| Risk of regressions         | None | High | Low |
| Boilerplate reduction       | Yes | Yes | Yes |
| Component API clarity       | Same | Best | Better |
| Call site changes (host app)| Opt-in | All 20 | Opt-in |
| Future-proofs splitting     | Yes | N/A | Yes |

## Recommendation

**Start with Option A** — add `autocomplete_field` and `text_autocomplete_field` helpers to FormMixin. This is zero-risk, immediately useful, and establishes the API contract. The `:show` mode stays as a direct `render AutocompleteComponent.new(...)` on index pages — it's not a form field, so it doesn't need a FormMixin helper.

**Consider Option C later** if `target_controller:` removal and scope normalization prove worthwhile after the helpers stabilize.

**Avoid Option B** unless the three modes genuinely start diverging in template or JS behavior. Currently the branching is ~10 lines of template and 2 methods in Ruby — not worth tripling the file count.
