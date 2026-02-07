# Dummy App Setup Guide

## Overview

The dummy app (`spec/dummy/`) is a minimal Rails application that demonstrates FlexiAdmin gem usage and enables integration testing. It must mirror the production app's (hriste) component chain pattern.

## Quick Start

```bash
cd spec/dummy
bin/dev          # Starts Rails + esbuild watch
# Visit http://localhost:9999/admin/users
```

## esbuild Configuration

### Watch Mode (Critical)

`esbuild.build()` compiles once and exits. For `bin/dev` to work, use `esbuild.context()`:

```javascript
// spec/dummy/esbuild.config.mjs
import * as esbuild from 'esbuild';

const config = {
  entryPoints: ['app/javascript/application.js'],
  bundle: true,
  outdir: 'app/assets/builds',
  // ... other options
};

const isWatch = process.argv.includes('--watch');

if (isWatch) {
  const ctx = await esbuild.context(config);
  await ctx.watch();
  console.log('Watching for changes...');
  // Process stays alive
} else {
  await esbuild.build(config);
}
```

### Procfile.dev

```
web: bin/rails server -p 9999
js: node esbuild.config.mjs --watch
```

## Component Chain Pattern

The dummy app MUST follow the same component hierarchy as production apps.

### File Structure

```
spec/dummy/app/components/admin/user/
├── index_page_component.rb           # Inherits from gem
├── index_page_component.html.slim    # Delegates to gem component
├── resources_component.rb            # Sets scope, views
├── resources_component.html.slim     # Renders ViewComponent
├── show_page_component.rb
├── show_page_component.html.erb
└── view/
    ├── list_view_component.rb        # Inherits from gem
    └── list_view_component.html.slim # Defines columns via DSL
```

### IndexPageComponent

**Ruby** - just inherit:
```ruby
module Admin::User
  class IndexPageComponent < FlexiAdmin::Components::Resources::IndexPageComponent
  end
end
```

**Template** - delegate to gem, customize filter:
```slim
= render FlexiAdmin::Components::Resources::IndexPageComponent.new(resources,
                                           scope: 'users',
                                           title: 'Users',
                                           context_params:) do |c|
  - c.with_filter
    = render FlexiAdmin::Components::Resource::FilterComponent.new(
        filter_options: { role: { options: [['user', 'User'], ['admin', 'Admin']] } },
        params:,
        search_field: text_field_tag('q', params[:q], placeholder: 'search...', class: 'form-control'),
        field_labels: { "q" => "Search", "role" => "Role" })

  = render Admin::User::ResourcesComponent.new(resources, context_params:)
```

### ResourcesComponent

```ruby
module Admin::User
  class ResourcesComponent < FlexiAdmin::Components::Resources::ResourcesComponent
    self.scope = 'users'      # Plural, matches route
    self.views = %w[list]     # Available views
    self.includes = %w[]      # Eager loading
  end
end
```

```slim
= render FlexiAdmin::Components::Resources::ViewComponent.new(context) do |c|
  - c.with_actions do
    = render FlexiAdmin::Components::Resources::SwitchViewComponent.new(context)

  - c.with_views do
    = render Admin::User::View::ListViewComponent.new(context)
```

### ListViewComponent

```ruby
module Admin::User::View
  class ListViewComponent < FlexiAdmin::Components::Resources::ListViewComponent
  end
end
```

```slim
= list_view do
  - selectable
  - column :full_name, label: 'Name', sortable: true do |user|
    - navigate_to user.full_name || '-', user
  - column :email, label: 'Email', sortable: true do |user|
    - navigate_to user.email, user
  - column :role, label: 'Role'
```

## Controller Pattern

Use gem's helper methods for consistency:

```ruby
module Admin
  class UsersController < ::ApplicationController
    include FlexiAdmin::Controllers::ResourcesController

    def index
      resources = ::User.all

      # Search (param: q)
      if params[:q].present?
        search_term = "%#{params[:q]}%"
        resources = resources.where('full_name LIKE ? OR email LIKE ?', search_term, search_term)
      end

      # Filter
      resources = resources.where(role: params[:role]) if params[:role].present?

      # Sort (helpers: fa_sorted?, fa_sort, fa_order)
      resources = if fa_sorted?
                    resources.order(fa_sort => fa_order)
                  else
                    resources.order(full_name: :asc)
                  end

      # Paginate (helper: context_params.pagination)
      resources = resources.paginate(**context_params.pagination)

      render_index(resources)
    end

    private

    def resource_class
      ::User
    end
  end
end
```

## FlexiAdmin Configuration

```ruby
# spec/dummy/config/initializers/flexi_admin.rb
FlexiAdmin::Config.configure do |config|
  config.namespace = 'admin'  # Routes namespace
end
```

## Database Setup

**CRITICAL**: Use file-based SQLite, not `:memory:`

```yaml
# spec/dummy/config/database.yml
test:
  adapter: sqlite3
  database: db/test.sqlite3
```

Schema defined in `spec/rails_helper.rb` via `ActiveRecord::Schema.define`.

## Stimulus Controllers

Located in `spec/dummy/app/javascript/controllers/`:

- `edit_controller.js` - Toggle form field disabled state
- `role_selector_controller.js` - Multi-button selector for role/type
- `search_controller.js` - Debounced search with Turbo
- `pagination_controller.js` - Per-page selector

Gem's controllers auto-registered from `flexi_admin/javascript/controllers/`:

- `bulk_action_controller.js` - Checkbox selection, counter
- `sorting_controller.js` - Column sort via Turbo Stream
- `filter_auto_submit_controller.js` - Form auto-submit on change

## Common Issues

### `bin/dev` exits immediately
→ esbuild config not using `context().watch()`

### Components don't render gem UI
→ Not following component chain pattern

### Sorting doesn't work
→ Controller using `params[:sort]` instead of `fa_sort`

### Search doesn't filter
→ Controller using `params[:search]` instead of `params[:q]`

### Tests fail with "no such table"
→ Using `:memory:` SQLite instead of file-based
