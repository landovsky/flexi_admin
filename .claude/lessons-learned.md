# Lessons Learned

## 2026-01-24 - Bulk Action Selection Persistence

### What went well
- Using `sessionStorage` for cross-pagination state was a clean solution that did not require server-side changes
- Scoping storage keys by `scopeValue` prevents conflicts between different resource types
- Leveraging Stimulus lifecycle (`connect`/`disconnect`) for state restoration works seamlessly with Turbo
- The existing `_populateIds()` method already worked correctly with the persisted `selectedIds` array - no changes needed

### What to avoid next time
- **Anonymous event listeners in Stimulus controllers**: When adding document-level event listeners in `connect()`, always store a bound reference so it can be properly removed in `disconnect()`. Example fix in `/Users/tomas/git/projects/flexi_admin_/lib/flexi_admin/javascript/controllers/bulk_action_controller.js`:
  ```javascript
  // Bad - cannot be removed
  document.addEventListener("event", (e) => this.handler(e));
  document.removeEventListener("event", this.handler); // Does not work!

  // Good - stored bound reference
  this._boundHandler = this.handler.bind(this);
  document.addEventListener("event", this._boundHandler);
  document.removeEventListener("event", this._boundHandler); // Works
  ```
- Consider edge cases with "select all" behavior when implementing cross-page selection. Does "select all" mean current page only or all pages?
- **Inconsistent scope identifiers across view modes**: When the same resource can be displayed in different views (list/table vs grid), ensure all components use the same scope identifier. Bug found in `card_component.html.slim` using `resource.class.name.downcase` (singular model name like "observation") while `table_component.html.slim` used `context.scope` (plural resource name like "inspections"). This caused checkboxes to have different `name` attributes, breaking cross-view selection persistence. Always use `context.scope` for consistency.

### Patterns to reuse
- **sessionStorage for Turbo frame state persistence**: When Turbo replaces content and Stimulus controllers reconnect, use sessionStorage to persist state between navigations. Pattern:
  ```javascript
  // In connect()
  this._loadFromStorage();
  this._restoreUIState();

  // After state changes
  this._saveToStorage();

  // Key scoped by unique identifier
  _storageKey() {
    return `feature_name_${this.scopeValue}`;
  }
  ```
- **Conditional target updates with `hasXxxTarget`**: Use Stimulus's built-in target existence checks before manipulating optional UI elements:
  ```javascript
  if (this.hasCounterTarget) {
    this.counterTarget.textContent = count;
  }
  ```
