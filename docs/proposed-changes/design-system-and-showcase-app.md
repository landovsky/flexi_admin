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

## Remaining work

- Visual review of tokens in light/dark themes on list, grid, show, edit pages.
- PR `feature/design-system` → `main`, release 0.0.8.
- Housekeeping (separate commit): `spec/dummy_old/`, committed `.gem` file, root status files.
