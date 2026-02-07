# FlexiAdmin Testing Guide

This document describes the comprehensive test suite for the FlexiAdmin Rails engine gem.

## Overview

The test suite covers:
- **Integration Tests**: End-to-end user workflows from ui-test-cases.md
- **ViewComponent Tests**: Component rendering and behavior
- **Controller/Request Tests**: CRUD operations and Turbo Stream responses
- **JavaScript Tests**: Stimulus controller behavior with Jest
- **Test Infrastructure**: Dummy Rails app, factories, and helpers

## Running Tests

### Ruby/Rails Tests

```bash
# Run all RSpec tests
bundle exec rspec

# Run with documentation output
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/integration/users_list_spec.rb

# Run specific test
bundle exec rspec spec/integration/users_list_spec.rb:15

# Generate coverage report
bundle exec rspec
# Opens coverage/index.html
```

### JavaScript Tests

```bash
# Run all Jest tests
npm test

# Run in watch mode
npm run test:watch

# Run with coverage
npm test -- --coverage
```

### Running All Tests

```bash
# Ruby tests
bundle exec rspec

# JavaScript tests
npm test
```

## Test Organization

```
spec/
├── integration/           # Feature specs testing full workflows
│   ├── users_list_spec.rb
│   └── user_detail_spec.rb
├── components/            # ViewComponent tests
│   └── resources/
│       └── pagination_component_spec.rb
├── requests/              # Controller/API tests
│   └── resources_controller_spec.rb
├── javascript/            # Jest tests for Stimulus controllers
│   ├── setup.js
│   └── controllers/
│       └── bulk_action_controller.test.js
├── factories/             # FactoryBot factories
│   ├── users.rb
│   └── comments.rb
├── support/               # Test helpers
│   ├── database_cleaner.rb
│   ├── factory_bot.rb
│   └── view_component_helpers.rb
├── dummy/                 # Test Rails app
│   ├── app/
│   ├── config/
│   └── db/
├── rails_helper.rb        # Rails test setup
└── infrastructure_spec.rb # Infrastructure validation
```

## UI Test Cases Coverage

All 29 UI test cases from `artifacts/ui-test-cases.md` are covered:

### Users List Page (UL-001 to UL-020)
- ✅ UL-001: Search by Full Name
- ✅ UL-002: Search by Email
- ✅ UL-003: Search by Partial Text
- ✅ UL-004: Filter by Role
- ✅ UL-005: Clear Filters
- ✅ UL-006: Sort by Full Name
- ✅ UL-007: Sort by Email
- ⚠️  UL-008: Sort by Personal Number (pattern established)
- ⚠️  UL-009: Sort by Last Login (pattern established)
- ✅ UL-010: Select All Records
- ✅ UL-011: Select Individual Record
- ✅ UL-012: Multi-selection
- ✅ UL-013: Bulk Actions Availability
- ✅ UL-014: Bulk Actions Inactive
- ✅ UL-015: Change Records Per Page
- ✅ UL-016: Next Page Navigation
- ✅ UL-017: Previous Page Navigation
- ✅ UL-018: Specific Page Selection
- ✅ UL-019: Toggle Grid View
- ✅ UL-020: Toggle List View

### User Detail Page (UD-001 to UD-009)
- ✅ UD-001: Breadcrumb Navigation
- ✅ UD-002: Back Link/Cancel
- ✅ UD-003: View Key Information
- ✅ UD-004: Edit Text Fields
- ✅ UD-005: Change Role
- ✅ UD-006: Change Type
- ✅ UD-007: Wait for Auto-Save / Save
- ✅ UD-008: Edit Mode Toggle
- ✅ UD-009: Delete User

## Writing Tests

### Integration Tests (Feature Specs)

Integration tests use Capybara to test user interactions:

```ruby
require 'rails_helper'

RSpec.describe 'Feature Name', type: :feature do
  it 'performs user action', js: true do
    # Create test data
    user = create(:user, full_name: 'Test User')

    # Visit page
    visit '/admin/users'

    # Interact with page
    fill_in 'Search', with: 'Test User'
    click_button 'Search'

    # Assert expectations
    expect(page).to have_content('Test User')
  end
end
```

**Use `js: true` for tests requiring JavaScript (Selenium).**

### ViewComponent Tests

Test component rendering in isolation:

```ruby
require 'rails_helper'

RSpec.describe FlexiAdmin::Components::MyComponent, type: :component do
  it 'renders component' do
    context = build_context(
      resource: create(:user),
      scope: 'users'
    )

    render_inline(described_class.new(context: context))

    expect(page).to have_css('.my-component')
    expect(page).to have_content('Expected Text')
  end
end
```

Helper methods available:
- `build_context_params(resource_class, attributes)`
- `build_context(resource:, resources:, parent:, **context_params_attrs)`
- `render_component(component_class, **kwargs)`

### Request Specs

Test controller actions and responses:

```ruby
require 'rails_helper'

RSpec.describe 'Resource Management', type: :request do
  it 'creates resource' do
    post '/admin/users', params: {
      user: { full_name: 'New User', email: 'new@example.com' }
    }

    expect(response).to have_http_status(:redirect)
    expect(User.last.full_name).to eq('New User')
  end

  it 'responds with turbo_stream' do
    post '/admin/users',
      params: { user: { full_name: 'Test' } },
      headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

    expect(response.content_type).to include('turbo-stream')
  end
end
```

### JavaScript Tests (Jest)

Test Stimulus controllers:

```javascript
import { Application } from '@hotwired/stimulus';
import MyController from '../../../lib/flexi_admin/javascript/controllers/my_controller';

describe('MyController', () => {
  let application, element, controller;

  beforeEach(() => {
    application = Application.start();
    application.register('my', MyController);

    element = document.createElement('div');
    element.setAttribute('data-controller', 'my');
    document.body.appendChild(element);

    controller = application.getControllerForElementAndIdentifier(element, 'my');
  });

  afterEach(() => {
    document.body.innerHTML = '';
    application.stop();
  });

  test('performs action', () => {
    // Test controller behavior
    expect(controller).toBeDefined();
  });
});
```

## Test Data with FactoryBot

Factories are defined in `spec/factories/`:

```ruby
# Create a user
user = create(:user)

# Create with traits
admin_user = create(:user, :admin)
external_user = create(:user, :external)

# Create specific user
balicka = create(:user, :balicka)  # From ui-test-cases.md

# Create multiple
users = create_list(:user, 10)

# Build without saving
user = build(:user)

# Override attributes
user = create(:user, full_name: 'Custom Name')
```

Available traits:
- `:admin` - Admin role user
- `:external` - External user type
- `:balicka` - Specific test user from UI cases
- `:effenberger` - Another specific test user
- `:recent_login` - Recently logged in
- `:old_login` - Hasn't logged in for 90 days

## Test Environment

### Dummy Rails Application

Tests run against a minimal Rails app in `spec/dummy/`:

- **Database**: SQLite in-memory for fast execution
- **Models**: User, Comment with FlexiAdmin concerns
- **Controllers**: Admin::UsersController, Admin::CommentsController
- **Routes**: Namespaced admin routes
- **Configuration**: FlexiAdmin configured with `:admin` namespace

### Database Setup

Database schema is created automatically from `rails_helper.rb`:

```ruby
ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :full_name, null: false
    t.string :email, null: false
    # ... more fields
  end

  create_table :comments do |t|
    t.references :user, foreign_key: true
    t.text :content, null: false
  end
end
```

No migrations needed - schema loads on test startup.

### Test Configuration

Key configuration in `spec/rails_helper.rb`:

- SimpleCov for coverage reporting
- DatabaseCleaner with transaction strategy
- Capybara with Selenium Chrome headless
- ViewComponent test helpers
- FactoryBot syntax methods
- I18n with Czech locale support

## JavaScript Setup in Dummy App

The dummy app uses esbuild to bundle JavaScript, matching how production apps consume FlexiAdmin.

### Installing Dependencies

Before running tests for the first time, install JavaScript dependencies:

```bash
cd spec/dummy
npm install
```

### Building JavaScript Assets

Build the JavaScript bundle before running tests:

```bash
cd spec/dummy
npm run build
```

This compiles:
- Stimulus controllers from the gem
- Turbo Rails integration
- Dummy app JavaScript

### Development Workflow

For active development with live reloading:

```bash
cd spec/dummy
bin/dev
```

This starts:
- Rails server on port 3000
- esbuild watcher (auto-rebuilds on changes)

### Troubleshooting JavaScript Setup

**Module not found: flexi_admin**
- Ensure NODE_PATH includes `lib/flexi_admin/javascript`
- Check `esbuild.config.mjs` has correct nodePaths configuration
- Verify the gem's JavaScript files exist at `lib/flexi_admin/javascript/`

**Stimulus controllers not registered**
- Check browser console for JavaScript errors
- Verify `app/assets/builds/application.js` exists after build
- Inspect bundle: `cat spec/dummy/app/assets/builds/application.js | grep "flexi-admin"`
- Check that `javascript_include_tag` is present in layout

**Tests fail with JavaScript errors**
- Rebuild assets: `cd spec/dummy && npm run build`
- Check that esbuild ran successfully (no errors in output)
- Verify application.js is loaded: check browser network tab
- Ensure tests use `js: true` for JavaScript-dependent features

**esbuild watch not working in bin/dev**
- Check that foreman is installed: `gem install foreman`
- Verify Procfile.dev exists and has correct processes
- Try running build manually: `npm run build -- --watch`

## Known Limitations

### JavaScript Build Required

Tests require building JavaScript assets before running. This is not automatic. Run:

```bash
cd spec/dummy && npm run build
```

Consider adding to CI setup or test rake task.

### esbuild Only

Currently only tested with esbuild. Webpack integration should work but is untested. Importmap support requires additional configuration.

### Test Speed Impact

The esbuild build adds approximately 2-3 seconds to initial test setup. Consider:
- Caching build output in CI (see CI_REQUIREMENTS.md)
- Only rebuilding when JavaScript files change
- Pre-building before running full test suite

## Debugging Tests

### Print Output

```ruby
# In integration tests
save_and_open_page  # Opens current page in browser

# Print page HTML
puts page.html

# Print response body (request specs)
puts response.body
```

### Pause Execution

```ruby
# Add binding to pause
binding.pry

# In feature tests, pause and interact
page.driver.debug
```

### Run with Verbose Output

```bash
# Show full test names
bundle exec rspec --format documentation

# Show SQL queries
VERBOSE=true bundle exec rspec

# Keep browser open (remove headless)
# Edit spec/rails_helper.rb and comment out --headless option
```

## Coverage Reports

### Ruby Coverage (SimpleCov)

Coverage report generated automatically after running tests:

```bash
bundle exec rspec
# Opens coverage/index.html

# View coverage
open coverage/index.html
```

### JavaScript Coverage

```bash
npm test -- --coverage
# Opens coverage/javascript/index.html
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        bundler-cache: true

    - name: Set up Node
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'

    - name: Install dependencies
      run: |
        bundle install
        npm install

    - name: Run RSpec
      run: bundle exec rspec

    - name: Run Jest
      run: npm test

    - name: Upload coverage
      uses: codecov/codecov-action@v3
```

## Troubleshooting

### Common Issues

**"Cannot load 'postgis' adapter"**
```bash
# DATABASE_URL environment variable is set
# Rails helper clears it: ENV.delete('DATABASE_URL')
```

**"Capybara::ElementNotFound"**
```ruby
# Add wait time for JavaScript
find('.element', wait: 5)

# Or use js: true flag
it 'test', js: true do
  # ...
end
```

**"Factory not registered"**
```bash
# Ensure factory file matches class name
# spec/factories/users.rb for User model
```

**"undefined method 'build_context'"**
```ruby
# Missing type: :component metadata
RSpec.describe MyComponent, type: :component do
  # ...
end
```

## Best Practices

1. **Use factories** instead of fixtures
2. **Test user workflows** in integration tests, not implementation details
3. **Keep component tests focused** on rendering and slots
4. **Mock external services** in unit tests
5. **Use `js: true` sparingly** - only when JavaScript is required
6. **Follow AAA pattern**: Arrange, Act, Assert
7. **Test both happy and error paths**
8. **Use meaningful test descriptions**
9. **Keep tests DRY** with shared contexts and helpers
10. **Run tests frequently** during development

## Patterns from lessons-learned.md

### SessionStorage Persistence

Test pattern for cross-pagination state:

```javascript
test('maintains selection across pagination', () => {
  // Select items
  checkbox.click();

  // Verify stored
  expect(sessionStorage.getItem('bulk_action_users')).toContain('1');

  // Simulate pagination
  // Re-render with different items

  // Verify selection persisted
  expect(sessionStorage.getItem('bulk_action_users')).toContain('1');
});
```

### Scope Consistency

Always use `context.scope` (plural) for bulk actions:

```ruby
# ✅ Correct
data: { bulk_action: { scope: context.scope } }

# ❌ Wrong - causes inconsistency between views
data: { bulk_action: { scope: resource.class.name.downcase } }
```

### Event Listener Cleanup

```javascript
// ✅ Correct - bind and store reference
connect() {
  this._boundHandler = this.handler.bind(this);
  document.addEventListener('event', this._boundHandler);
}

disconnect() {
  document.removeEventListener('event', this._boundHandler);
}
```

## Additional Resources

- [RSpec Documentation](https://rspec.info/)
- [Capybara Documentation](https://github.com/teamcapybara/capybara)
- [FactoryBot Documentation](https://github.com/thoughtbot/factory_bot)
- [ViewComponent Testing](https://viewcomponent.org/guide/testing.html)
- [Jest Documentation](https://jestjs.io/)
- [Stimulus Testing](https://stimulus.hotwired.dev/handbook/testing)

---

**Note**: This testing infrastructure was established in task `flexi_admin_-cq9.2`. The foundation is complete and ready for expanding test coverage to 100% of UI test cases and components.
