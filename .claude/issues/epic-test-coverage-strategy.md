# Epic: Test Coverage Strategy for flexi_admin Gem

## Summary
Establish comprehensive test coverage for the flexi_admin Rails engine gem, starting with infrastructure setup (dummy Rails app), followed by ViewComponent tests as the primary focus, and including JavaScript/Stimulus controller tests. Target is approximately 50% test coverage as an initial milestone.

Based on .claude/analysis/test-coverage-strategy-context.md

## Background
The flexi_admin gem currently has minimal test coverage (2 spec files: version test and Struct model test). As a Rails engine with 37+ ViewComponents, 17 Stimulus controllers, controller concerns, and models, a proper testing infrastructure is needed to ensure reliability and enable confident refactoring.

## Tasks

### Phase 1: Infrastructure Setup
**Estimated effort: Large**

Set up the foundational testing infrastructure including a dummy Rails application, test gems, and helper configuration.

**Deliverables:**
- [ ] Add test dependencies to gemspec:
  - `capybara`
  - `selenium-webdriver`
  - `factory_bot_rails`
  - `database_cleaner-active_record`
  - `rspec-rails`
- [ ] Create `spec/dummy/` Rails application structure:
  ```
  spec/dummy/
    app/
      controllers/
        application_controller.rb
        admin/
          posts_controller.rb      # Uses ResourcesController concern
          comments_controller.rb   # Child resource for parent tests
      models/
        application_record.rb
        post.rb                    # Parent model with ApplicationResource
        comment.rb                 # Child model (belongs_to :post)
        author.rb                  # For additional relationship testing
    config/
      application.rb
      boot.rb
      environment.rb
      environments/test.rb
      routes.rb
      database.yml
      initializers/
        flexi_admin.rb            # Configure FlexiAdmin namespace
    db/
      migrate/
        001_create_posts.rb
        002_create_comments.rb
        003_create_authors.rb
      schema.rb
    bin/
      rails
  ```
- [ ] Configure `spec/rails_helper.rb`:
  - Load dummy Rails app
  - Include `ViewComponent::TestHelpers`
  - Include `FactoryBot::Syntax::Methods`
  - Configure DatabaseCleaner strategy
  - Set up I18n backend
  - Configure GlobalID for test models
- [ ] Create `spec/support/` helpers:
  - `view_component_helpers.rb` - custom matchers for component testing
  - `factory_bot.rb` - FactoryBot configuration
  - `database_cleaner.rb` - database cleaning between tests
- [ ] Create factories:
  - `spec/factories/posts.rb`
  - `spec/factories/comments.rb`
  - `spec/factories/authors.rb`
- [ ] Verify setup with a smoke test that renders a simple component

**Technical notes:**
- Dummy app must configure `FlexiAdmin::Config.configuration.namespace` (e.g., `:admin`)
- Test models need `include FlexiAdmin::Concerns::ApplicationResource` for GlobalID support
- Routes must mount the FlexiAdmin engine and define resource routes

---

### Phase 2: Pure Ruby Model Tests
**Estimated effort: Small**

Test the pure Ruby classes that don't require Rails context. These serve as quick wins and establish testing patterns.

**Deliverables:**
- [ ] `spec/unit/models/context_params_spec.rb`
  - Parameter mapping (permit, merge, pagination params)
  - Edge cases (nil values, empty params)
- [ ] `spec/unit/models/toast_spec.rb`
  - Toast message formatting
  - Different toast types (success, error, warning)
- [ ] `spec/unit/models/context_spec.rb`
  - Context building from params
  - Parent/child context handling
- [ ] `spec/unit/config/store_spec.rb`
  - Configuration get/set
  - Default values
  - Namespace configuration

**Technical notes:**
- These tests should run without loading Rails (use `spec_helper.rb` not `rails_helper.rb`)
- Follow existing pattern from `spec/models/struct_spec.rb`
- Keep tests fast by avoiding database/Rails dependencies

---

### Phase 3: ViewComponent Tests (Priority)
**Estimated effort: Extra Large**

Test the 37+ ViewComponents which form the bulk of the gem. Start with simple components and progress to complex ones with slots.

**Deliverables:**

#### 3a. Simple Components (no slots, minimal dependencies)
- [ ] `spec/components/shared/alert_component_spec.rb`
- [ ] `spec/components/shared/link_component_spec.rb`
- [ ] `spec/components/shared/button_component_spec.rb`
- [ ] `spec/components/shared/icon_component_spec.rb`
- [ ] `spec/components/shared/badge_component_spec.rb`

#### 3b. Form Components
- [ ] `spec/components/forms/label_component_spec.rb`
- [ ] `spec/components/forms/text_input_component_spec.rb`
- [ ] `spec/components/forms/text_area_component_spec.rb`
- [ ] `spec/components/forms/select_component_spec.rb`
- [ ] `spec/components/forms/checkbox_component_spec.rb`
- [ ] `spec/components/forms/form_component_spec.rb`

#### 3c. Resource Components (use ActiveRecord, need factories)
- [ ] `spec/components/resources/table_component_spec.rb`
- [ ] `spec/components/resources/row_component_spec.rb`
- [ ] `spec/components/resources/cell_component_spec.rb`
- [ ] `spec/components/resources/pagination_component_spec.rb`

#### 3d. Complex Components (slots, nested components)
- [ ] `spec/components/resources/index_page_component_spec.rb`
- [ ] `spec/components/resources/show_page_component_spec.rb`
- [ ] `spec/components/resources/form_page_component_spec.rb`
- [ ] `spec/components/layouts/page_component_spec.rb`

#### 3e. Modal and Turbo Components
- [ ] `spec/components/modals/modal_component_spec.rb`
- [ ] `spec/components/modals/confirm_component_spec.rb`
- [ ] `spec/components/turbo/frame_component_spec.rb`

**Technical notes:**
- Use `render_inline(ComponentClass.new(...))` pattern from ViewComponent
- Test rendered HTML with Capybara matchers (`have_css`, `have_text`)
- For components with slots, test with block syntax
- Components using `main_app` helper need routes available
- Mock or stub ContextParams where needed for isolation

---

### Phase 4: Controller Tests
**Estimated effort: Medium**

Test the controller concerns through the dummy app controllers.

**Deliverables:**
- [ ] `spec/requests/admin/posts_spec.rb`
  - Index action (with pagination, filtering)
  - Show action
  - New/Create actions
  - Edit/Update actions
  - Destroy action
- [ ] `spec/requests/admin/comments_spec.rb`
  - Nested resource CRUD (parent context)
  - Parent propagation via GlobalID
- [ ] `spec/requests/modals_spec.rb`
  - Turbo Stream responses for modals
  - Modal form submissions
- [ ] `spec/requests/bulk_actions_spec.rb`
  - Bulk selection
  - Bulk action execution

**Technical notes:**
- Use request specs (not controller specs) for Rails 7+ compatibility
- Test Turbo Stream responses with `expect(response.media_type).to eq Mime[:turbo_stream]`
- Set up `@routes = FlexiAdmin::Engine.routes` for engine route testing
- Test both HTML and Turbo Stream response formats

---

### Phase 5: JavaScript/Stimulus Tests
**Estimated effort: Large**

Set up JavaScript testing infrastructure and test the 17 Stimulus controllers.

**Deliverables:**

#### 5a. JavaScript Testing Infrastructure
- [ ] Add JS test dependencies to `package.json`:
  - `jest`
  - `@hotwired/stimulus` (testing utilities)
  - `jsdom`
  - `@testing-library/dom`
- [ ] Configure `jest.config.js`
- [ ] Create test setup file with Stimulus application mock
- [ ] Add npm test script

#### 5b. Stimulus Controller Tests (Priority controllers)
- [ ] `spec/javascript/controllers/bulk_action_controller.test.js`
  - Selection persistence (sessionStorage)
  - Checkbox toggling
  - Selection count updates
- [ ] `spec/javascript/controllers/autocomplete_controller.test.js`
  - Fetch behavior
  - Result rendering
  - Selection handling
- [ ] `spec/javascript/controllers/form_controller.test.js`
  - Form submission handling
  - Validation display
- [ ] `spec/javascript/controllers/modal_controller.test.js`
  - Open/close behavior
  - Turbo Frame integration

#### 5c. Additional Stimulus Controllers
- [ ] `spec/javascript/controllers/tabs_controller.test.js`
- [ ] `spec/javascript/controllers/dropdown_controller.test.js`
- [ ] `spec/javascript/controllers/flash_controller.test.js`
- [ ] `spec/javascript/controllers/clipboard_controller.test.js`

**Technical notes:**
- Mock `sessionStorage` and `localStorage` in jsdom environment
- Use `@hotwired/stimulus/testing` utilities if available
- Test controller lifecycle (connect, disconnect)
- Test action handlers and target bindings
- For complex DOM interactions, consider supplementing with Capybara system tests

---

## Dependencies

```
Phase 1 (Infrastructure)
    |
    +---> Phase 2 (Pure Ruby Models) - can run in parallel with 3a
    |
    +---> Phase 3a (Simple Components)
              |
              +---> Phase 3b (Form Components)
              |         |
              |         +---> Phase 3c (Resource Components)
              |                   |
              |                   +---> Phase 3d (Complex Components)
              |                             |
              |                             +---> Phase 3e (Modal/Turbo)
              |
              +---> Phase 4 (Controller Tests) - after 3c
    |
    +---> Phase 5 (JavaScript Tests) - independent after Phase 1
```

**Key constraints:**
- Phase 1 must complete before any Rails-dependent tests
- Phase 2 can run in parallel with Phase 3a (different helpers)
- Phase 3 should progress from simple to complex components
- Phase 4 requires factories and test models from Phase 1
- Phase 5 is independent of Ruby tests but needs Phase 1 for dummy app routes

## Acceptance Criteria

### Epic-level Criteria
- [ ] Test suite runs successfully with `bundle exec rspec`
- [ ] JavaScript tests run with `npm test` or `yarn test`
- [ ] Test coverage reaches approximately 50% (measured by SimpleCov or similar)
- [ ] All tests pass in a fresh clone of the repository
- [ ] README updated with test running instructions

### Phase-specific Criteria

**Phase 1:**
- [ ] `bundle exec rspec spec/dummy_smoke_spec.rb` passes
- [ ] Dummy app can boot and serve requests
- [ ] Factories create valid records
- [ ] GlobalID resolves test models correctly

**Phase 2:**
- [ ] All pure Ruby model specs pass without Rails loaded
- [ ] Fast execution (< 1 second for all Phase 2 tests)

**Phase 3:**
- [ ] At least 20 of 37+ components have test coverage
- [ ] Tests cover both render output and slot functionality
- [ ] Edge cases tested (nil values, empty collections)

**Phase 4:**
- [ ] All CRUD actions tested for primary resource
- [ ] Nested resource (parent/child) flows tested
- [ ] Turbo Stream responses verified

**Phase 5:**
- [ ] Jest runs successfully
- [ ] At least 5 priority Stimulus controllers tested
- [ ] sessionStorage/localStorage mocking works

## Out of Scope

- **CI/CD configuration** - GitHub Actions setup is explicitly excluded; focus is on local test setup
- **CanCan/authorization testing** - Authorization integration tests deferred to future work
- **Performance/load testing** - Not included in this coverage effort
- **100% coverage target** - Initial milestone is ~50%; comprehensive coverage is future work
- **Visual regression testing** - No screenshot comparison tools
- **API documentation generation** - Focus is on test coverage, not docs
- **Mutation testing** - Standard coverage metrics only
- **Cross-browser JavaScript testing** - Jest with jsdom only; no Selenium browser matrix

## Technical References

### ViewComponent Testing
```ruby
# spec/components/shared/alert_component_spec.rb
require "rails_helper"

RSpec.describe FlexiAdmin::Components::Shared::AlertComponent, type: :component do
  it "renders success alert" do
    render_inline(described_class.new(type: :success, message: "Done!"))

    expect(page).to have_css(".alert.alert-success")
    expect(page).to have_text("Done!")
  end
end
```

### Controller Testing
```ruby
# spec/requests/admin/posts_spec.rb
require "rails_helper"

RSpec.describe "Admin::Posts", type: :request do
  let!(:post) { create(:post) }

  describe "GET /admin/posts" do
    it "renders index" do
      get admin_posts_path
      expect(response).to have_http_status(:success)
    end
  end
end
```

### Stimulus Testing
```javascript
// spec/javascript/controllers/bulk_action_controller.test.js
import { Application } from "@hotwired/stimulus"
import BulkActionController from "flexi_admin/controllers/bulk_action_controller"

describe("BulkActionController", () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div data-controller="bulk-action">
        <input type="checkbox" data-bulk-action-target="checkbox" />
      </div>
    `
    const application = Application.start()
    application.register("bulk-action", BulkActionController)
  })

  it("toggles selection", () => {
    // test implementation
  })
})
```

## Files Referenced from Context
- `/Users/tomas/git/projects/flexi_admin_/spec/models/struct_spec.rb` - Existing test pattern to follow
- `/Users/tomas/git/projects/flexi_admin_/spec/spec_helper.rb` - Current RSpec configuration
- `/Users/tomas/git/projects/flexi_admin_/lib/flexi_admin/components/` - 37+ components to test
- `/Users/tomas/git/projects/flexi_admin_/lib/flexi_admin/javascript/controllers/` - 17 Stimulus controllers
