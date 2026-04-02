# Enhanced Autocomplete — Decision Log

**Branch:** `enhanced-autocomplete`
**Date:** 2026-04-02
**Author:** Jon LaPLante

---

## Overview

This document records the design and implementation decisions made for the enhanced autocomplete feature added to the FlexiAdmin gem. The feature augments the existing `AutocompleteComponent` and its Stimulus controller with two operating modes, keyboard navigation, match highlighting, pre-loaded results, and additional developer-configurable options.

---

## Decision Log

### 1. Scope: Augmentation, Not Replacement

**Decision:** The new functionality augments the existing `AutocompleteComponent` and `autocomplete` Stimulus controller. It does not replace them or introduce a parallel component.

**Rationale:** FlexiAdmin is a gem used across multiple projects. A clean, additive change to the existing component preserves all existing integrations and avoids duplication. All new behavior is opt-in via explicit configuration.

---

### 2. Default Mode: `:search`

**Decision:** The new `mode:` parameter defaults to `:search`.

**Rationale:** Preserves existing behavior entirely for all current consumers of the gem. No changes are visible to existing integrations unless they explicitly opt into `:select` mode.

---

### 3. Search Mode Result Count: Multiple Ranked Results

**Decision:** Search mode returns multiple results, ranked with `starts_with?` matches first, followed by `includes?` matches — up to `result_limit`.

**Rationale:** Industry standard for admin UI record selectors (ActiveAdmin, Administrate, Select2, Tom Select, etc.) is multiple ranked results. Returning a single result was considered and rejected as an antipattern for data-heavy admin tools where users may need to distinguish between similar records.

---

### 4. Stimulus Controller: Augment In Place

**Decision:** New behavior is added directly to the existing `autocomplete` Stimulus controller file. No new controller is introduced.

**Rationale:** Since this is a gem update, all consumers receive the updated controller on upgrade. New methods and behavior are additive and only activate when new configuration options are explicitly set. A separate controller would create confusion and duplication with no meaningful benefit.

---

### 5. `result_limit` Default: 100 (Preserves Current Behavior)

**Decision:** `result_limit` defaults to `100`, matching the current hardcoded server-side limit.

**Rationale:** The second spec suggested a default of `10`, but applying that as a gem-wide default would silently reduce the result count for all existing search-mode integrations — a quiet regression contradicting the requirement that existing behavior be completely unchanged. Developers adopting select mode should tune `result_limit` explicitly for their use case.

**Consequence acknowledged:** A default of `100` is high for select mode's pre-loaded list; developers are expected to set `result_limit` (and `preload_count`) explicitly when using `:select` mode.

---

### 6. `result_limit` Scope: Server-Side Query Limit

**Decision:** `result_limit` controls the server-side `LIMIT` on the query, replacing the current hardcoded `100`. It is passed as a query parameter from the frontend.

**Rationale:** Client-side capping of a server-side result set provides false efficiency — the server still does the work. Controlling the limit at the query level is cleaner and more performant.

---

### 7. `preload_count` Passed as Query Parameter

**Decision:** When select mode fires an empty-query fetch on focus, `preload_count` is passed as a query parameter so the backend applies it as the limit for that request.

**Rationale:** The backend remains mode-agnostic — it receives a standard `limit` parameter regardless of whether the request is a focus-triggered preload or a typed search. No backend awareness of frontend mode is required.

---

### 8. Highlighted Matching: Server-Side, `<mark>` Tags

**Decision:** Match highlighting is implemented server-side in `ResultsComponent`, wrapping matched substrings in `<mark>` tags before the HTML fragment is returned. It is developer-configurable via a `highlight_matches:` boolean.

**Rationale:** Server-side is the standard Rails approach (used by pg_search, Ransack, and similar libraries). The query string `q` is already available on the server at render time. This avoids client-side DOM manipulation after HTML injection, eliminates XSS risk, and keeps the Stimulus controller simple. The `<mark>` element is the semantic HTML standard for highlighted/matched text.

---

### 9. Section Labels: i18n

**Decision:** The "Suggested" and "Search results" dropdown section labels are defined as i18n keys, not hardcoded strings.

**Rationale:** FlexiAdmin already uses i18n (the existing codebase contains Czech locale strings). Hardcoded English strings would be inconsistent with the gem's existing localisation approach and would not be usable in non-English applications.

**`show_preload_label: false`** hides both labels entirely.

---

### 10. Keyboard Navigation: Select Mode Only

**Decision:** Arrow Up/Down, Enter, and Escape keyboard navigation is implemented for `:select` mode only. Search mode retains its existing keyboard behavior (Tab and Enter to accept, click to select).

**Rationale:** Search mode's current keyboard behavior is considered correct and complete. Keyboard navigation is a select mode requirement because it presents a multi-item list that users need to traverse without a mouse.

---

### 11. `debounce_ms` Default: 200ms

**Decision:** `debounce_ms` defaults to `200`, matching the current hardcoded debounce delay.

**Rationale:** The second spec suggested `300ms` as a default, but changing the default would alter timing behavior for all existing search-mode integrations. Defaulting to `200ms` preserves current behavior exactly.

---

### 12. `simulate_loading` Dropped

**Decision:** The `simulate_loading` option from the second spec is not implemented.

**Rationale:** It was introduced for visual mockup testing purposes only and has no value in a production gem.

---

## New Configuration Parameters Summary

| Parameter | Type | Default | Notes |
|---|---|---|---|
| `mode:` | `:search`, `:select` | `:search` | `:search` preserves all existing behavior |
| `preload_count:` | Integer | `10` | Select mode only; passed to backend as limit on focus fetch |
| `result_limit:` | Integer | `100` | Replaces hardcoded server-side LIMIT of 100 |
| `min_chars:` | Integer (0–3) | `1` | Characters required before debounced search fires |
| `debounce_ms:` | Integer | `200` | Debounce delay; defaults to current hardcoded value |
| `highlight_matches:` | Boolean | `false` | Wraps matched substrings in `<mark>` tags server-side |
| `show_preload_label:` | Boolean | `true` | Shows "Suggested" / "Search results" section headers |
| `placeholder_style:` | Developer-set | Current default | Developer controls placeholder text |

---

## Files Affected

| File | Change Type |
|---|---|
| `lib/flexi_admin/components/resource/autocomplete_component.rb` | Augmented — new params |
| `lib/flexi_admin/components/resource/autocomplete_component.html.slim` | Augmented — focus action for select mode |
| `lib/flexi_admin/javascript/controllers/autocomplete_controller.js` | Augmented — new methods, keyboard nav, focus handler |
| `lib/flexi_admin/controllers/resources_controller.rb` | Augmented — blank query handling, `result_limit` param |
| `lib/flexi_admin/components/shared/autocomplete/results_component.rb` | Augmented — highlight support, query param, labels |
| `lib/flexi_admin/components/shared/autocomplete/results_component.html.slim` | Augmented — `<mark>` rendering, i18n labels |
| `config/locales/en.yml` | Augmented — i18n keys for section labels |
