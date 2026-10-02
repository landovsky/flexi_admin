# FlexiAdmin Rails

FlexiAdmin is a Rails engine that provides a flexible admin interface with modern JavaScript integration using Stimulus controllers and Turbo.

## Installation

**Gemfile**

1. Add to your `Gemfile`:

```ruby
gem 'flexi_admin', git: 'https://github.com/landovsky/flexi_admin.git', branch: 'main'
```

2. Run `bundle install`

## Setup

### Stylesheets

Add to `app/assets/stylesheets/application.scss`:

```scss
@import "flexi_admin.scss";
```

### JavaScript Integration

FlexiAdmin works with modern JavaScript bundlers. Choose your bundler below:

#### With esbuild (Recommended)

Add to `app/javascript/application.js`:

```javascript
import "flexi_admin"
```

**esbuild Configuration:**

The gem's Railtie automatically sets up NODE_PATH to include the FlexiAdmin JavaScript directory. If you're using a custom esbuild configuration, ensure it can resolve the gem's JavaScript:

```javascript
// esbuild.config.mjs
import * as esbuild from 'esbuild'
import path from 'path'

await esbuild.build({
  entryPoints: ['app/javascript/application.js'],
  bundle: true,
  sourcemap: true,
  format: 'esm',
  outdir: 'app/assets/builds',
  publicPath: '/assets',
  nodePaths: [
    './node_modules',
    // Path to gem JavaScript (adjust if needed)
    path.resolve('../flexi_admin/lib/flexi_admin/javascript')
  ]
})
```

Or set NODE_PATH in your package.json build script:

```json
{
  "scripts": {
    "build": "NODE_PATH=./node_modules:$(bundle show flexi_admin)/lib/flexi_admin/javascript esbuild app/javascript/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds"
  }
}
```

#### With webpack

Add to `app/javascript/application.js`:

```javascript
import "flexi_admin"
```

**Webpack Configuration:**

Update your webpack configuration to resolve the gem's JavaScript directory:

```javascript
// webpack.config.js
const path = require('path')

module.exports = {
  resolve: {
    modules: [
      path.resolve(__dirname, 'node_modules'),
      // Add gem JavaScript directory
      path.resolve(__dirname, '../flexi_admin/lib/flexi_admin/javascript')
    ]
  }
}
```

Or find the gem path dynamically:

```javascript
const { execSync } = require('child_process')
const gemPath = execSync('bundle show flexi_admin').toString().trim()

module.exports = {
  resolve: {
    modules: [
      'node_modules',
      path.join(gemPath, 'lib/flexi_admin/javascript')
    ]
  }
}
```

### Stimulus Controllers

FlexiAdmin includes 19 Stimulus controllers that automatically register when you import the gem's JavaScript:

#### Available Controllers

- `add-row` - Dynamically add rows to forms
- `autocomplete` - Autocomplete search fields
- `bulk-action` - Bulk selection with persistence across pagination
- `button-select` - Custom button selection controls
- `datalist` - Enhanced datalist inputs
- `delete` - Confirmation dialogs for delete actions
- `filter-auto-submit` - Auto-submit filters on change
- `floating-toc` - Floating table of contents navigation
- `form` - Enhanced form behavior
- `form-validation` - Client-side form validation
- `pagination` - Page navigation controls
- `sorting` - Column sorting
- `switch-view` - Toggle between list/grid views
- `tabs` - Keeps the open `TabsComponent` tab in the URL hash
- `toast` - Toast notification system
- `trix` - Rich text editor integration
- `uploads` - File upload handling

#### Usage in Views

Use controllers in your ERB templates with the `data-controller` attribute:

```erb
<div data-controller="flexi-admin--bulk-action"
     data-flexi-admin--bulk-action-scope-value="users">
  <!-- Your bulk action content -->
</div>
```

Controller naming convention: `flexi-admin--[controller-name]`

#### Example: Pagination

```erb
<nav data-controller="flexi-admin--pagination">
  <%= link_to "Previous",
      admin_users_path(page: @page - 1),
      data: {
        turbo_frame: "users_list",
        action: "flexi-admin--pagination#navigate"
      } %>
</nav>
```

#### Example: Bulk Actions with Selection

```erb
<div data-controller="flexi-admin--bulk-action"
     data-flexi-admin--bulk-action-scope-value="users">

  <%= check_box_tag "select_all", nil, false,
      data: { action: "flexi-admin--bulk-action#toggleAll" } %>

  <% @users.each do |user| %>
    <%= check_box_tag "user_ids[]", user.id, false,
        data: {
          action: "flexi-admin--bulk-action#toggle",
          flexi_admin__bulk_action_target: "checkbox"
        } %>
  <% end %>

  <%= button_to "Delete Selected",
      bulk_action_admin_users_path,
      data: {
        flexi_admin__bulk_action_target: "actionButton",
        confirm: "Are you sure?"
      } %>
</div>
```

#### Example: Autocomplete Search

```erb
<%= text_field_tag :search, params[:search],
    data: {
      controller: "flexi-admin--autocomplete",
      flexi_admin__autocomplete_url_value: autocomplete_admin_users_path,
      action: "input->flexi-admin--autocomplete#search"
    } %>
```

#### Example: Tabs on a show page

`FlexiAdmin::Components::Shared::TabsComponent` splits a long page into Bootstrap tabs. Every
pane is rendered up front (no lazy loading), so content behaves exactly as it did on one page.
The open tab is kept in the URL hash (`/orders/1#kalkulace`), so a reload or a shared link
reopens it.

```slim
= render FlexiAdmin::Components::Shared::TabsComponent.new(id: 'order') do |tabs|
  - tabs.with_tab(key: 'prehled', label: 'Přehled')
    = render Admin::Order::Show::EditFormComponent.new(resource)
  - tabs.with_tab(key: 'kalkulace', label: 'Kalkulace', count: calculations.size)
    = render Admin::OrderCalculation::ResourcesComponent.new(calculations, context_params:, parent: resource)
```

- `id:` prefixes the DOM ids (`order-tab-<key>`, `order-pane-<key>`). It must be unique on the page.
- `with_tab(key:, label:, count: nil, active: false)`: `count` renders a badge, and `active: true` opens that tab
  (the first tab otherwise).
- `remember: false` turns off the URL-hash memory, for example for a second tab set on the same page.
- `nav_class:` sets the classes on the `ul.nav-tabs` (default `mb-4`).

Requires Bootstrap 5's JavaScript (`data-bs-toggle="tab"`).

### Verification

To verify the JavaScript is loading correctly:

1. Start your Rails server
2. Open browser console
3. Check for Stimulus registration:

```javascript
// Should list all FlexiAdmin controllers
window.Stimulus.controllers
```

## Temporary Workarounds

Currently, the following manual steps are required:

### Modals Controller

Create a modals controller in your app:

```ruby
# app/controllers/modals_controller.rb
class ModalsController < AdminController
  include FlexiAdmin::Controllers::ModalsController
end
```

Add to routes:

```ruby
resources :modals, only: [] do
  get :show, on: :collection
end
```

## Development

See [TESTING.md](TESTING.md) for information on:
- Running the test suite
- Setting up the dummy app for development
- JavaScript build process
- Test coverage

## Documentation

- [TESTING.md](TESTING.md) - Testing guide and infrastructure
- [CI_REQUIREMENTS.md](CI_REQUIREMENTS.md) - CI/CD setup for esbuild
- [spec/dummy/README.md](spec/dummy/README.md) - Dummy app documentation

## License

This project is licensed under the MIT License.
