# Context: Test Coverage Strategy for flexi_admin Gem

## Request summary
Analyze strategies for creating test coverage for the flexi_admin gem. Determine whether a dummy Rails app approach is needed, explore alternatives, and understand what aspects of the gem need testing.

## Codebase structure

### Gem type
- **Rails Engine gem** using `Rails::Engine` (isolated namespace)
- Provides ViewComponents, controller concerns, models, services, helpers, and JavaScript/Stimulus controllers
- Dependencies: Rails 7.1+, ViewComponent 3.20, will_paginate, slim-rails, gemini-ai

### Key directories
- `lib/flexi_admin/` - Main library code
  - `components/` - 37+ ViewComponents with .slim templates
  - `controllers/` - Controller concerns (ResourcesController, ModalsController)
  - `models/` - Struct, ContextParams, Toast, Context classes
  - `services/` - CreateResource, UpdateResource
  - `helpers/` - ApplicationHelper and component helpers
  - `javascript/controllers/` - 17 Stimulus controllers
- `spec/` - Existing minimal test setup
- `config/locales/` - i18n files

### Current test state
- Basic RSpec setup exists (`spec/spec_helper.rb`, `.rspec`)
- Only 2 spec files:
  - `spec/flexi_admin_spec.rb` - version test only
  - `spec/models/struct_spec.rb` - comprehensive tests for Struct class
- **No ViewComponent tests**
- **No controller tests**
- **No integration tests**
- **No JavaScript tests**
- **No dummy Rails app**

## Relevant codebase areas

### Pure Ruby classes (easy to test without Rails)
- `lib/flexi_admin/models/struct.rb` - Already tested, good pattern
- `lib/flexi_admin/models/context_params.rb` - Parameter handling, testable in isolation
- `lib/flexi_admin/config.rb` - Configuration store

### ViewComponents (need Rails context)
- `lib/flexi_admin/components/base_component.rb` - Base class
- `lib/flexi_admin/components/shared/alert_component.rb` - Simple component, good test candidate
- `lib/flexi_admin/components/resources/index_page_component.rb` - Complex with slots

### Controllers (need full Rails stack)
- `lib/flexi_admin/controllers/resources_controller.rb` - Concern with CRUD actions
- `lib/flexi_admin/controllers/modals_controller.rb` - Turbo stream responses

### JavaScript (need JS testing framework)
- `lib/flexi_admin/javascript/controllers/bulk_action_controller.js` - Complex Stimulus controller
- 17 total Stimulus controllers in `lib/flexi_admin/javascript/controllers/`

## Existing patterns to follow

### Test structure from struct_spec.rb
```ruby
# Uses context blocks for scenarios
# Tests both happy path and error cases
# Uses let blocks for test subjects
RSpec.describe FlexiAdmin::Models::Struct do
  describe ".new" do
    context "with positional attributes" do
      let(:person_class) { FlexiAdmin::Models::Struct.new(:name, :age) }
      it "creates a class with the specified attributes" do
        # ...
      end
    end
  end
end
```

### spec_helper.rb configuration
```ruby
require "flexi_admin"
RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
```

## Testing strategies

### Option 1: Dummy Rails application (Recommended)
Standard Rails engine testing pattern. Create `spec/dummy/` with minimal Rails app.

**Structure:**
```
spec/
  dummy/
    app/
      controllers/
        application_controller.rb
        admin/
          posts_controller.rb  # Example using FlexiAdmin
      models/
        post.rb  # Test model
    config/
      application.rb
      routes.rb
      database.yml
    db/
      migrate/
        create_posts.rb
  rails_helper.rb
  support/
    view_component_helpers.rb
  components/
    alert_component_spec.rb
  controllers/
    resources_controller_spec.rb
  system/
    bulk_action_spec.rb  # Capybara + JS
```

**Pros:**
- Tests real integration with Rails
- Can test Turbo Stream responses
- Can test routes and URL helpers
- Industry standard for Rails engines

**Cons:**
- More setup overhead
- Need to maintain dummy app
- Database migrations for test models

### Option 2: Minimal Rails context (Lighter weight)
Use combustion gem or manual minimal setup without full dummy app.

```ruby
# spec/rails_helper.rb
require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "view_component"
require "flexi_admin"

module DummyApp
  class Application < Rails::Application
    config.eager_load = false
  end
end
Rails.application.initialize!
```

**Pros:**
- Faster test suite
- Less maintenance
- Good for unit-level component tests

**Cons:**
- Can't test full integration flows
- No database for model tests
- Limited controller testing

### Option 3: Hybrid approach (Best of both)
Use minimal setup for unit tests, dummy app only for integration/system tests.

```
spec/
  unit/           # No Rails, fast
    struct_spec.rb
    context_params_spec.rb
  components/     # Minimal Rails context
    alert_component_spec.rb
  dummy/          # Full Rails app
  integration/    # Uses dummy app
    resources_controller_spec.rb
  system/         # Uses dummy app + Capybara
    bulk_action_spec.rb
```

## Technical constraints

### ViewComponent testing requirements
- Needs `ViewComponent::TestHelpers` for `render_inline`
- Requires `ApplicationController` or configured controller class
- Components using `main_app` helper need routes defined
- Slots testing requires block syntax

### Controller concern testing
- Must test as included module, not standalone
- Need dummy controller that includes the concern
- Turbo Stream responses need `turbo-rails` gem

### JavaScript testing options
1. **Jest + Stimulus testing library** - Unit test Stimulus controllers
2. **Capybara + Selenium** - System tests with real browser
3. **Playwright** - Modern alternative to Selenium

### Database requirements
- Components like `IndexPageComponent` expect ActiveRecord relations
- `ApplicationResource` concern expects `gid_param` (GlobalID)
- Parent/child relationships use `GlobalID::Locator`

## Risks and sharp edges

### Tight Rails coupling
- Components deeply integrated with Rails view context
- `main_app` helper delegation requires host app routes
- `helpers` delegation in BaseComponent needs view context

### Missing abstractions for testing
- No factory pattern for test data
- Components expect real ActiveRecord models
- No mock/stub helpers for ContextParams

### Configuration dependency
- `FlexiAdmin::Config.configuration.namespace` used extensively
- `FlexiAdmin::Config.configuration.module_namespace` for class resolution
- Tests must configure these or handle `nil` cases

### Turbo/Stimulus complexity
- Many components render Turbo Streams
- Stimulus controllers have complex DOM interactions
- `bulk_action_controller.js` uses sessionStorage - hard to test

### I18n dependency
- `config/locales/en.yml` loaded by engine
- Tests need I18n backend configured

## Recommended implementation plan

### Phase 1: Setup infrastructure
1. Add test gems to gemspec:
   ```ruby
   spec.add_development_dependency "capybara"
   spec.add_development_dependency "selenium-webdriver"
   spec.add_development_dependency "factory_bot_rails"
   spec.add_development_dependency "database_cleaner-active_record"
   ```
2. Create `spec/dummy/` Rails app
3. Configure `spec/rails_helper.rb` with ViewComponent helpers
4. Create test model (e.g., `Post`) with ApplicationResource concern

### Phase 2: Unit tests (Pure Ruby)
1. `ContextParams` - parameter mapping, merge, pagination
2. `Config::Store` - configuration handling
3. `Models::Toast` - toast message formatting
4. `Models::Resources::Context` - context building

### Phase 3: Component tests
1. Simple components first: `AlertComponent`, `LinkComponent`
2. Form components: `LabelComponent`, `TextInputComponent`
3. Complex components: `IndexPageComponent`, `ResourcesComponent`

### Phase 4: Controller tests
1. Create dummy controller including `ResourcesController`
2. Test CRUD actions
3. Test Turbo Stream responses
4. Test authorization (CanCan integration)

### Phase 5: System tests
1. Test bulk action selection across pagination
2. Test autocomplete functionality
3. Test form submissions with Turbo

### Phase 6: JavaScript tests
1. Set up Jest with Stimulus testing utilities
2. Test `bulk_action_controller.js` storage persistence
3. Test `autocomplete_controller.js` fetch behavior

## Open questions

1. **Test data strategy**: Should tests use FactoryBot, fixtures, or inline object creation?
2. **CanCan testing**: How to test authorization without full CanCan setup?
3. **JavaScript test runner**: Jest vs Rails system tests for Stimulus controllers?
4. **CI configuration**: GitHub Actions? What Ruby/Rails matrix?
5. **Coverage threshold**: What percentage to target initially?
6. **Namespace testing**: How to test components with configured vs unconfigured namespace?
7. **GlobalID in tests**: Need to configure GlobalID for test models

## Files to reference

### For ViewComponent testing patterns
- ViewComponent docs: https://viewcomponent.org/guide/testing.html
- Example: `config.include ViewComponent::TestHelpers, type: :component`

### For Rails engine testing
- Rails Guides: https://guides.rubyonrails.org/engines.html#testing-an-engine
- Key: `@routes = FlexiAdmin::Engine.routes` in controller tests

### Existing test examples in codebase
- `spec/models/struct_spec.rb` - Good unit test pattern
- `spec/spec_helper.rb` - Current configuration
