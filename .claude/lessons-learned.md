# Lessons Learned

## 2026-02-07 - Selenium + SQLite + DatabaseCleaner

### Critical: SQLite :memory: does NOT work with Selenium

**Problem**: All 27 integration tests failed with `SQLite3::SQLException: no such table: users`

**Root cause**: SQLite `:memory:` databases are **connection-specific**. Selenium runs the Rails app in a separate thread which gets a different database connection = empty database with no tables.

**Solution**: Use file-based SQLite for test environment:
```yaml
# spec/dummy/config/database.yml
test:
  adapter: sqlite3
  database: db/test.sqlite3  # NOT ":memory:"
```

### Critical: Transactional fixtures break JS tests

**Problem**: Even with file-based SQLite, tests failed because Selenium couldn't see test data.

**Root cause**: `config.use_transactional_fixtures = true` wraps each test in a transaction. The browser process (Selenium/Chrome) runs in a separate connection that can't see uncommitted transaction data.

**Solution**: Use DatabaseCleaner with truncation strategy for JS tests:
```ruby
config.use_transactional_fixtures = false

config.before(:suite) { DatabaseCleaner.clean_with(:truncation) }
config.before(:each) do |example|
  DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
end
config.before(:each) { DatabaseCleaner.start }
config.after(:each) { DatabaseCleaner.clean }
```

### Pattern: Debugging Selenium test failures

1. Check for `no such table` errors → SQLite :memory: issue
2. Check for "element not found" when data should exist → transactional fixtures issue
3. Use `HEADED=1 bundle exec rspec` to watch browser
4. Screenshots auto-saved to `spec/tmp/capybara/` on failure

## 2026-02-07 - esbuild Watch Mode

### Problem: `bin/dev` exits immediately

**Root cause**: `esbuild.build()` compiles and exits. Watch mode requires different API.

**Solution**: Check for `--watch` flag and use `esbuild.context()` + `ctx.watch()`:
```javascript
const isWatch = process.argv.includes('--watch');

if (isWatch) {
  const ctx = await esbuild.context(config);
  await ctx.watch();
  console.log('Watching for changes...');
  // Don't exit - process stays alive
} else {
  await esbuild.build(config);
}
```

## 2026-02-07 - FlexiAdmin Component Chain Pattern

### Problem: Custom dummy app components didn't render gem's UI features

**Root cause**: Dummy app had standalone components that didn't use the gem's component chain.

**Solution**: Mirror production app (hriste) pattern exactly:

```
IndexPageComponent.html.slim (delegates to gem's component)
  └── with_filter slot → FilterComponent
  └── body → ResourcesComponent
        └── ViewComponent (turbo-frame, bulk-action controller)
              └── ListViewComponent (table columns via DSL)
```

**Key files**:
```ruby
# index_page_component.rb - just inherit
class Admin::User::IndexPageComponent < FlexiAdmin::Components::Resources::IndexPageComponent
end

# resources_component.rb - set scope and views
class Admin::User::ResourcesComponent < FlexiAdmin::Components::Resources::ResourcesComponent
  self.scope = 'users'
  self.views = %w[list]
end

# list_view_component.rb - inherit
class Admin::User::View::ListViewComponent < FlexiAdmin::Components::Resources::ListViewComponent
end
```

**Templates delegate to gem**, only customizing what's needed:
```slim
# index_page_component.html.slim
= render FlexiAdmin::Components::Resources::IndexPageComponent.new(resources, scope: 'users', ...) do |c|
  - c.with_filter
    = render FlexiAdmin::Components::Resource::FilterComponent.new(...)
  = render Admin::User::ResourcesComponent.new(resources, context_params:)
```

### Controller conventions

Use gem's helper methods, not raw params:
```ruby
def index
  resources = ::User.all
  resources = resources.where('name LIKE ?', "%#{params[:q]}%") if params[:q].present?
  resources = if fa_sorted?
                resources.order(fa_sort => fa_order)
              else
                resources.order(name: :asc)
              end
  resources = resources.paginate(**context_params.pagination)
  render_index(resources)
end
```

**Param conventions**:
- Search: `q` (not `search`)
- Sort: `fa_sort`, `fa_order` (accessed via `fa_sorted?`, `fa_sort`, `fa_order`)
- Pagination: `fa_page`, `fa_per_page` (accessed via `context_params.pagination`)

## 2026-02-07 - Capybara Test Patterns for FlexiAdmin

### Sorting uses Turbo Stream - URL doesn't change

```ruby
# WRONG - URL doesn't change with Turbo Stream
expect(page).to have_current_path(/fa_sort=name/)

# CORRECT - check DOM attribute
within('flexi-table') do
  sort_el = find('[data-controller="sorting"]', text: 'Name')
  expect(sort_el['data-sorting-sort-path-value']).to match(/fa_order=desc/)
end
```

### Hidden elements need visibility option

```ruby
# WRONG - can't find element with display:none
expect(find('[data-bulk-action-target="selectionText"]')).not_to be_visible

# CORRECT - specify visibility
expect(page).to have_css('[data-bulk-action-target="selectionText"]', visible: :hidden)
```

### Turbo confirm works with accept_confirm

```ruby
accept_confirm('Are you sure?') { click_link 'Delete' }
```

---

## 2026-01-24 - Bulk Action Selection Persistence

### What went well
- Using `sessionStorage` for cross-pagination state was a clean solution that did not require server-side changes
- Scoping storage keys by `scopeValue` prevents conflicts between different resource types
- Leveraging Stimulus lifecycle (`connect`/`disconnect`) for state restoration works seamlessly with Turbo

### What to avoid
- **Anonymous event listeners in Stimulus controllers**: Always store bound reference for removal in `disconnect()`
- **Inconsistent scope identifiers**: Always use `context.scope` (plural), never `resource.class.name.downcase` (singular)

### Patterns to reuse
- **sessionStorage for Turbo frame state persistence**
- **Conditional target updates with `hasXxxTarget`**

---

## 2026-02-02 - Test Infrastructure for Rails Engine

### What worked well
- FactoryBot traits for common test data patterns
- SimpleCov coverage reporting integration

### What to avoid (UPDATED)
- ~~Using in-memory SQLite~~ → **MUST use file-based SQLite for Selenium tests**
- **`ENV['RAILS_ENV'] ||= 'test'` can fail**: Use `ENV['RAILS_ENV'] = 'test'`
- **Namespaced controllers must use `::ApplicationController`**

### Process improvements
- **For Rails Engine testing**: Integration tests need working component stack that mirrors production
- **Test layers**: Infrastructure tests separate from integration tests
