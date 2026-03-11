# Lessons Learned

## 2026-03-11 - Turbo Frame reload after bulk actions

### What worked well
- **Scope-aware frame reload via `_reload_frame.slim` partial**: Instead of `window.location.reload()`, setting `frame.src` via JS on the existing turbo-frame element keeps content visible until new content arrives, eliminating flicker. The old content stays in place during the fetch — unlike `turbo_stream.replace` with an empty frame which removes content first.
- **JS-based hidden field injection for modal forms**: The modal template (`modal_component.html.slim`) renders the `<form>` inside the `modal_form` slot. Hidden fields placed outside the slot end up as siblings of the `<form>`, not children — so they never get submitted. The working pattern is to inject hidden fields via JS in `bulk_action_controller.js#_modalOpened`, consistent with how `ids` and `processor` are already added.
- **Fallback chain in `reload_frame`**: `fa_reload_frame` > `fa_scope` > `resource_class.model_name.plural` gives zero-config behavior for standard components while allowing explicit overrides for custom forms.

### What to avoid
- **Putting hidden inputs in `modal_component.html.slim` outside the `modal_form` slot**: The slot renders a `FormElementComponent` which contains the actual `<form>` tag. Anything after `= modal_form` in the template is outside the form and won't be submitted. This is non-obvious from reading the Slim template alone.
- **Assuming `resource_class.model_name.plural` matches the turbo-frame ID**: When actions use `self.class_name = OtherModel` (like `ArchivedObservationImage` using `ObservationImage`), the controller's `resource_class` diverges from the actual frame scope on the page. Always pass scope explicitly in these cases.
- **Overloading `scope` for unrelated purposes**: `scope` means "resource collection identity" (used for frame IDs, checkbox grouping, modal IDs, session storage). Using it to mean "reload target" for custom non-resource frames muddies the concept. The `fa_reload_frame` param was introduced to keep these concerns separate.

### Process improvements
- **When dismissing Bootstrap modals via Turbo Streams, clean up aggressively**: `modal.hide()` alone isn't enough — also remove `.modal-backdrop` elements and clear `modal-open` class / inline styles from `<body>`. Turbo Stream DOM updates can interrupt Bootstrap's cleanup lifecycle.
- **Wrap custom (non-ResourcesComponent) sections in turbo-frames if they need post-action refresh**: Sections rendered as plain loops (like "Nezpracovan fotky") can't benefit from frame reload unless wrapped in a `<turbo-frame>`. This is a one-line template change that enables smooth partial page updates.
