---
title: Design Token System and Showcase Dummy App
status: in-progress
date: 2026-10-05
---

# Design Token System and Showcase Dummy App

Branch: `feature/design-system`

## Context

Two related efforts, started in April/May 2026, stalled, and restarted in October 2026:

1. **Design tokens** (`ed9b57f`) — SCSS design tokens (`app/assets/stylesheets/_tokens.scss`,
   `_base.scss`) so host apps can theme flexi_admin by overriding CSS custom properties
   instead of patching component styles. Component stylesheets (autocomplete, form,
   button_select, grid card, toast, trix) were migrated to the tokens.
2. **Showcase app** — `spec/dummy` turned from a bare test fixture into an annotated reference
   app: the place to *see* the tokens applied and to read living documentation of every DSL.

## What the showcase contains

- All labels in English (were Czech).
- `FLEXI ADMIN EXAMPLE:` doc blocks in every component/controller, documenting the form DSL,
  list-column options, grid-card DSL, bulk-action processor, filter options and controller
  conventions.
- Remaining ERB templates converted to Slim.
- Broader feature coverage:
  - list **and** grid view (`views = %w[list grid]`, `GridViewComponent`)
  - row-level `actions_dropdown`, custom `role_badge` column, extra columns
  - second filter (`user_type`, multi-select), index subtitle
  - edit form exercising `header`, `columns`, `select_field`, `button_select_field`,
    `number_field`, `datetime_field`
  - nested resource: `Admin::Comment::*` component set rendered on the user show page with
    `parent:`, `CommentsController` as a real nested FlexiAdmin controller
- `config/environments/development.rb` so the dummy can be served as a demo
  (Tailscale host `hp-ubuntu.skunk-escalator.ts.net:3999` allowlisted).

## Problems found on restart (2026-10-05)

| Problem | Effect | Resolution |
|---|---|---|
| Nested `Comment::ResourcesComponent` builds `admin_comments_path`, only `admin_user_comments_path` exists | user show page 500s (9 spec failures) | gem: parent-aware path building (see below) |
| Integration specs assert Czech labels | ~2 failures | specs updated |
| Per-row actions dropdown makes `within('.dropdown')` ambiguous | 4 failures | specs scoped to the bulk-action container |
| `config.hosts <<` added to `test.rb` | enables host authorization → request specs 403 | removed from test env |
| `development.rb` was a copy of `test.rb` | no code reloading, CSRF off, exceptions swallowed | replaced with standard dev config |
| Global `RUBYOPT=-r~/.ruby_net_http_fix` | `bundle exec rspec` fails (net-protocol conflict) | `bin/rspec` wrapper clears it |
| `~/.local/bin/chromedriver` symlink to snap wrapper | snap dispatches on argv[0] → driver never starts | `bin/rspec` sets `SE_CHROMEDRIVER` |

## Parent-aware paths for nested resources

Decision: fix in the gem rather than adding a top-level `resources :comments` route to the
dummy. A resources list rendered with `parent:` should build paths through the parent's
nested route (`admin_user_comments_path(user)`) when that route exists, and fall back to the
flat route otherwise. A top-level route would only hide the bug for the dummy app.

## Visual review (2026-10-05)

Dev server, list / grid / show / edit pages, light and forced dark (`prefers-color-scheme: dark`
+ `data-bs-theme="dark"`).

Fixed during the review:

| Finding | Fix |
|---|---|
| List view: custom column blocks written with Slim `=` leaked above the table; cells showed wrong content | gem: `ListViewComponent` captures column blocks (both `=` output and return values work) + regression spec |
| No icons anywhere (edit/delete, view switch, row actions blank) | dummy layout loads Bootstrap Icons; README documents it as a host requirement. Also un-pended `shows alphabet icon` spec |
| Active pagination number and selected button-select label invisible (muted/grey text on primary) | new `--fa-on-primary` token used by `.btn-primary` and active page link |
| Show page 500 in development: `GlobalID.app` unset | dummy requires `global_id/railtie` (tests masked it by setting `GlobalID.app` in `rails_helper`) |
| `button_select_field` demo passed `[label, value]` pairs | plain values + `labels:` |

Fixed in a follow-up round (user-reported): `datetime_field` now `datetime-local` (native
picker); filter bar, pagination and list columns aligned (dummy's leftover `components.css`
removed, `flexi-table` cells `min-width: 0`); checkbox outlines get `--fa-border-control`
(3.4:1, was 1.27:1); `as: :date` shows dates; `TabsComponent` showcased on the user page.

**Dark theme (2026-10-05).** `:root[data-bs-theme="dark"]` token block (lighter indigo
primary with dark text on it; every text pair ≥4.5:1, control outlines ≥3:1), `-rgb`
companions so Bootstrap utilities (`.bg-body`, `.bg-body-tertiary`) follow the tokens,
`--fa-on-primary` / `--fa-on-danger` wherever text sits on a colored fill, hard-coded
`bg-white`/`bg-light`/`text-dark` utilities replaced. `Nav::ThemeScriptComponent` (pre-paint,
localStorage, follows OS on `auto`) + `Nav::ThemeToggleComponent` / `theme` Stimulus
controller. Verified by full-page screenshots of every dummy page (list, grid, show + both
tabs, edit, nested comments index, autocomplete, form fields, bulk/filter menus, modal) in
both themes. Also fixed on the way: nested comments index 500 (missing IndexPageComponent,
parent from `:user_id`), modal count spacing, dummy test pages' hard-coded colors.

Open findings (not fixed):

1. **Hard-coded Czech UI strings in the gem**: `Akce`, `Uložit`, `Zrušit`, `záznamů`,
   `vybráno … zrušit výběr`, `vybraných položek`, `Aktivní filtry`. Should go through I18n with
   `en`/`cs` locale files.
2. **`fa_view` shown as an active filter** ("Aktivní filtry: Fa view: grid") after switching to
   grid view — internal `fa_*` params should be excluded from the filter summary.
3. **Breadcrumbs**: collection crumb is singular ("User" for `/admin/users`); `Admin` crumb is
   not a link.
4. **Grid cards** reserve a large empty image area when the resource has no image.

## Remaining work

- Gem I18n (open finding 1) — the biggest remaining gap before the design system is done.
- PR `feature/design-system` → `main`, release 0.0.8.
- Housekeeping (separate commit): `spec/dummy_old/`, committed `.gem` file, root status files.
