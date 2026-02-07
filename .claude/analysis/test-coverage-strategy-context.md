# Context: Test Coverage Strategy for flexi_admin Gem

## Request summary
Analyze strategies for creating test coverage for the flexi_admin gem. Determine whether a dummy Rails app approach is needed, explore alternatives, and understand what aspects of the gem need testing.

## Requirements
- [ ] !!! integration tests. The test strategy must perform end-to-end tests (see ui-test-cases.md)
- [ ] run "bundle exec rspec --format d" and save the documentation into a file for easy human reading of test coverage (especially in the ingeration layer)

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
