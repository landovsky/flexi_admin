# Front-end Feature Testing with Capybara

## Infrastructure

- **Framework**: RSpec + Capybara + Selenium + Chrome
- **Config files**: `spec/support/capybara.rb`, `spec/rails_helper.rb`
- **Test location**: `spec/integration/` (feature specs)
- **Run with visible browser**: `HEADED=1 bundle exec rspec spec/integration/`

## Strict Requirements

### DatabaseCleaner: truncation for JS tests

JS tests run Chrome in a separate process. It **cannot see data inside a DB transaction**. The `spec/support/database_cleaner.rb` selects strategy based on `js` metadata:

```ruby
config.before(:each) do |example|
  DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
end
```

**Never** wrap JS tests in `DatabaseCleaner.cleaning` with transaction strategy - data will be invisible to the browser.

### All feature specs should use `js: true`

The dummy app UI depends on Stimulus controllers and Turbo. Tests that interact with JavaScript components require `js: true`.

### Authentication via test helpers

The dummy app uses simple test authentication helpers (no Devise yet):

```ruby
let(:admin_user) { create(:user, :admin) }

before do
  login_as(admin_user, scope: :user)
end
```

Currently, `login_as` is a placeholder that sets `@current_test_user`. When Devise is added, this will integrate with Warden test helpers.

## Recommendations

### Scope interactions to avoid ambiguous matches

FlexiAdmin component labels may match multiple elements on the page. Always scope interactions when possible:

```ruby
within('.breadcrumb') { click_link 'Uživatel' }
within('.page-header') { click_button 'Edit' }
within('.bulk-actions') { click_button 'Delete Selected' }
```

### Use custom matchers for cleaner tests

The project provides custom RSpec matchers in `spec/support/matchers/component_matchers.rb`:

```ruby
expect(page).to have_sortable_column('full_name')
expect(page).to have_pagination_controls
expect(page).to have_per_page_selector
expect(page).to have_bulk_actions
expect(page).to have_search_field
expect(page).to have_success_message('User updated successfully')
```

### Use shared examples for common patterns

Shared examples are available in `spec/support/shared_examples/resource_index.rb`:

```ruby
RSpec.describe 'Users Index', type: :feature do
  it_behaves_like 'a resource index page', 'users', :user
  it_behaves_like 'a resource with bulk actions', 'users', :user
  it_behaves_like 'a filterable resource index', 'users', ['role', 'user_type']
end
```

### Search field behavior

The search implementation depends on the specific component. Check the controller action to understand the behavior:

```ruby
# Example: searching users
fill_in 'q', with: 'search term'
# May require explicit form submission or JS trigger depending on implementation
```

### Debugging techniques

| Technique | When to use |
|---|---|
| Read component source | First approach - understand component structure |
| Capybara error messages | Usually sufficient for fixing failures |
| `puts page.text[0..2000]` | Check what text is visible on page |
| `HEADED=1` | Watch the browser execute the test |
| `binding.pry` + `page.all('.selector').map(&:text)` | Interactive element inspection |
| `save_screenshot` | Auto-captured on JS test failure (see spec/tmp/capybara/) |

### FlexiAdmin component patterns

The dummy app demonstrates FlexiAdmin gem patterns:

- Index pages use `FlexiAdmin::Components::Resources::IndexPageComponent`
- Show pages extend `FlexiAdmin::Components::Resources::ShowPageComponent`
- Components use ViewComponent architecture with slots
- Stimulus controllers handle interactivity (edit, search, pagination, bulk actions)
- Turbo Streams provide seamless updates without page reloads

### Bootstrap 5 integration

The dummy app uses Bootstrap 5 for styling:

- Forms use `.form-control`, `.form-select`, `.form-group` classes
- Buttons use `.btn`, `.btn-primary`, `.btn-secondary` classes
- Tables use `.table` class
- Toasts use Bootstrap toast component with `.toast`, `.toast-container`
- Dropdowns use Bootstrap dropdown with `data-bs-toggle="dropdown"`

### Turbo Stream expectations

When testing actions that use Turbo Streams:

```ruby
it 'updates user without page reload', js: true do
  visit admin_user_path(user)

  click_button 'Edit'
  fill_in 'Full Name', with: 'Updated Name'
  click_button 'Save'

  # Turbo stream should update content in-place
  expect(page).to have_content('Updated Name')
  expect(page).to have_success_message('User updated successfully')

  # No full page reload occurred
  expect(current_path).to eq(admin_user_path(user))
end
```

### Factory traits

Use factory traits for realistic test data:

```ruby
create(:user, :admin)              # Admin user
create(:user, :external)           # External user
create(:user, :with_comments)      # User with 3 comments
create(:user, :inactive)           # Last login 6 months ago
create(:user, :power_user)         # 200-1000 sign-ins
create(:user, :never_logged_in)    # Never logged in
```

### Screenshot debugging

Screenshots are automatically saved on JS test failures:

```bash
# Location: spec/tmp/capybara/
# Format: {spec_file}-{line_number}-{timestamp}.png

# To manually capture a screenshot:
page.save_screenshot('debug.png')
```

### Common Capybara gotchas

1. **Wait for async updates**: Use `have_content` not `page.text.include?`
   ```ruby
   # Good - waits for content
   expect(page).to have_content('Success')

   # Bad - doesn't wait
   expect(page.text).to include('Success')
   ```

2. **Element visibility**: Use `visible: :all` to find hidden elements
   ```ruby
   find('input[type="hidden"]', visible: :all)
   ```

3. **Ambiguous matches**: Be specific with selectors
   ```ruby
   # Good
   click_button 'Edit', match: :first

   # Better
   within('.page-header') { click_button 'Edit' }
   ```

4. **Form field labels**: Match exact label text
   ```ruby
   # If label is "Jméno a příjmení"
   fill_in 'Jméno a příjmení', with: 'Test User'
   ```

## Example test patterns

### Basic resource index test

```ruby
RSpec.describe 'Users List', type: :feature, js: true do
  let!(:users) { create_list(:user, 5) }

  before do
    visit admin_users_path
  end

  it 'displays all users' do
    users.each do |user|
      expect(page).to have_content(user.full_name)
    end
  end

  it 'has search functionality' do
    expect(page).to have_search_field

    fill_in 'q', with: users.first.full_name
    # Add search trigger if needed

    expect(page).to have_content(users.first.full_name)
  end
end
```

### Testing Stimulus controllers

```ruby
it 'enables bulk actions when users selected', js: true do
  visit admin_users_path

  # Stimulus controller should be connected
  expect(page).to have_stimulus_controller('flexi-admin--bulk-action')

  # Select a user
  first('input[type="checkbox"]').check

  # Bulk actions should be enabled
  expect(page).to have_css('.bulk-actions:not([disabled])')
end
```

### Testing Turbo Stream responses

```ruby
it 'deletes user via Turbo Stream', js: true do
  user = create(:user)
  visit admin_users_path

  within("#user-#{user.id}") do
    click_button 'Delete'
  end

  # Turbo stream removes the element
  expect(page).not_to have_css("#user-#{user.id}")

  # Shows success toast
  expect(page).to have_success_message('User deleted successfully')
end
```
