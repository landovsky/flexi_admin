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

## 2026-02-02 - flexi_admin_-cq9 - Test Infrastructure for Rails Engine

### What worked well
- Using an in-memory SQLite database (`:memory:`) for test isolation and speed
- Defining schema directly in rails_helper.rb avoids migration complexity
- FactoryBot traits for common test data patterns (`:admin`, `:balicka`, etc.)
- SimpleCov coverage reporting integration

### What to avoid
- **`ENV['RAILS_ENV'] ||= 'test'` can fail**: If RAILS_ENV is set to empty string or inherited from shell, the `||=` operator won't override it. Always use `ENV['RAILS_ENV'] = 'test'` in rails_helper.rb for reliable test environment.
- **`config.paths['app/controllers']` doesn't configure autoloading**: For dummy Rails apps, you must explicitly add directories to `config.autoload_paths` and `config.eager_load_paths` for Rails to find controllers/models.
- **Testing FlexiAdmin components in isolation is complex**: Components use route helpers (`users_path`), Context objects, and ContextParams with specific APIs. Isolated ViewComponent tests may need extensive mocking or should be replaced with request-level tests.
- **Namespaced controllers must use `::ApplicationController`**: Inside `module Admin`, writing `ApplicationController` looks for `Admin::ApplicationController`. Use `::ApplicationController` for the global class.

### Process improvements
- **For Rails Engine testing**: Always verify the environment is `test` early in test boot (add `raise if Rails.env != 'test'` temporarily if debugging)
- **Document component constructor signatures**: Components like `PaginationComponent.new(context, per_page:, page:)` mix positional and keyword args - tests need to match exactly
- **Integration tests need working component stack**: UI test cases (from ui-test-cases.md) that test actual page interactions require either: (1) real FlexiAdmin components configured for test models, or (2) system tests with the full application
- **Consider test layers**: Infrastructure tests (model creation, factory loading) should be separate from integration tests (full page rendering) - easier to diagnose failures

### Patterns to reuse
- **Dummy Rails app structure for engine testing**:
  ```
  spec/dummy/
    app/
      controllers/
        application_controller.rb
        admin/users_controller.rb
      models/
        application_record.rb
        user.rb
    config/
      application.rb  # with autoload_paths configured
      database.yml    # sqlite3 :memory:
      routes.rb
      environments/test.rb
  ```
- **ViewComponent test context builder**:
  ```ruby
  def build_context(resource:, resources:, scope:)
    params = FlexiAdmin::Models::ContextParams.new({ 'fa_scope' => scope })
    FlexiAdmin::Models::Resources::Context.new(resources, scope, params, { parent: nil })
  end
  ```
