# Front-end Feature Testing with Capybara

## Infrastructure

- **Framework**: RSpec + Capybara + Selenium + Chrome
- **Config files**: `spec/support/capybara.rb`, `spec/rails_helper.rb`
- **Test location**: `spec/integration/` (feature specs)
- **Run with visible browser**: `HEADED=1 bundle exec rspec spec/integration/`
- **Database**: SQLite (file-based for test — in-memory won't work with Selenium)

## Strict Requirements

### DatabaseCleaner: truncation for JS tests

JS tests run Chrome in a separate process. It **cannot see data inside a DB transaction**. The `rails_helper.rb` selects strategy based on `js` metadata:

```ruby
config.use_transactional_fixtures = false

config.before(:suite) { DatabaseCleaner.clean_with(:truncation) }
config.before(:each) do |example|
  DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
end
config.before(:each) { DatabaseCleaner.start }
config.after(:each) { DatabaseCleaner.clean }
```

**Never** use `use_transactional_fixtures = true` with JS tests — data will be invisible to the browser.

### SQLite in-memory database won't work with JS tests

SQLite `:memory:` databases are connection-specific. Selenium runs the app in a separate thread with a different connection = empty database. Use **file-based SQLite**:

```yaml
test:
  adapter: sqlite3
  database: db/test.sqlite3
```

### All feature specs must use `js: true`

The admin UI depends on Stimulus controllers, Bootstrap JS, and Turbo. Tests without `js: true` use rack_test (no browser, no JS):

```ruby
RSpec.describe 'Users List Page', type: :feature, js: true do
```

### No authentication required (dummy app)

The dummy app has no authentication. No `login_as` needed.

## Recommendations

### Scope filter interactions to `.filter-bar`

FlexiAdmin filter dropdown labels often match column headers, causing `Capybara::Ambiguous` errors:

```ruby
within('.filter-bar') { select 'Admin', from: 'role' }
```

### Search uses `q` parameter

The search field name is `q`. Use URL params for direct search:

```ruby
visit '/admin/users?q=search+term'
```

Or fill in the field and trigger focusout (filter-auto-submit controller):

```ruby
fill_in 'q', with: 'search term'
find('[name="q"]').native.send_keys(:tab)
```

### Sorting uses Turbo Stream (URL doesn't change)

Sorting is handled by the `sorting` Stimulus controller which fetches via Turbo Stream. Don't check `current_path` — check the DOM:

```ruby
within('flexi-table') do
  find('[data-controller="sorting"]', text: 'Jméno').find('a').click
end
# After sort, the path value toggles to desc
within('flexi-table') do
  sort_el = find('[data-controller="sorting"]', text: 'Jméno')
  expect(sort_el['data-sorting-sort-path-value']).to match(/fa_order=desc/)
end
```

### Pagination uses `fa_page` and `fa_per_page` params

```ruby
visit '/admin/users?fa_page=2'
within('.pagination') { click_link '→' }
expect(page).to have_css('.page-item.active', text: '2')
```

### Bulk selection checkboxes

```ruby
# Select all
find('#checkbox-all').click

# Individual checkboxes (exclude "select all")
checkboxes = page.all('.bulk-action-checkbox input[type="checkbox"]').reject { |cb| cb[:id] == 'checkbox-all' }
checkboxes.first.click

# Check selection counter
expect(find('[data-bulk-action-target="counter"]').text).to eq('1')

# Clear selection
click_link 'zrušit výběr'
expect(page).to have_css('[data-bulk-action-target="selectionText"]', visible: :hidden)
```

### Hidden elements need `visible: :hidden` or `visible: :all`

Selection text starts hidden (`display: none`). Use:

```ruby
expect(page).to have_css('[data-bulk-action-target="selectionText"]', visible: :hidden)
```

### Delete uses Turbo confirm, not browser confirm

Turbo 8 uses `data-turbo-confirm` which triggers browser's `confirm()`. Use:

```ruby
accept_confirm('Are you sure?') { click_link 'Delete' }
```

### Debugging techniques

| Technique | When to use |
|---|---|
| Read source (Slim, Stimulus, FlexiAdmin gem) | First approach — predict UI structure |
| `puts page.text[0..2000]` | Check what text is visible on page |
| `HEADED=1` | Watch the browser execute the test |
| `save_and_open_screenshot` | Capture rendered state including JS |
| Screenshot on failure | Auto-saved to `spec/tmp/capybara/` |

## Dummy app component chain

The dummy app mirrors the real app's (hriste) component chain:

```
IndexPageComponent (slim template delegates to gem's component)
  └── FilterComponent (search field + role filter)
  └── ResourcesComponent (sets scope='users', views=['list'])
        └── ViewComponent (turbo-frame, bulk-action controller, pagination)
              └── ListViewComponent (table columns via list_view DSL)
                    └── TableComponent (flexi-table, headers, rows, checkboxes)
```

Each layer inherits from the gem's base class and only overrides what's needed.

### Controller pattern (align with gem's conventions)

```ruby
def index
  resources = ::User.all
  resources = resources.where('full_name LIKE ?', "%#{params[:q]}%") if params[:q].present?
  resources = resources.where(role: params[:role]) if params[:role].present?
  resources = if fa_sorted?
                resources.order(fa_sort => fa_order)
              else
                resources.order(full_name: :asc)
              end
  resources = resources.paginate(**context_params.pagination)
  render_index(resources)
end
```
