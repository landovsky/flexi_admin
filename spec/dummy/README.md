# FlexiAdmin Dummy App

This is a minimal Rails 7 application used for testing the FlexiAdmin engine gem.

## Purpose

The dummy app exercises FlexiAdmin features with:

- **Two models**: User and Comment (demonstrating nested resources)
- **Full CRUD operations**: Create, Read, Update, Delete with all FlexiAdmin features
- **Custom components**: Examples showing how to extend FlexiAdmin components
- **JavaScript integration**: Tests Stimulus controllers and Turbo integration

### What Gets Tested

- Search, filtering, sorting, pagination
- Nested resources (users have many comments)
- Bulk actions with cross-pagination persistence
- Custom page components with slots
- Stimulus controller integration
- Turbo Streams responses
- Form validation and error handling

## JavaScript Setup

The dummy app uses **esbuild** to bundle JavaScript, matching how production applications consume FlexiAdmin.

### Key Files

- `package.json` - Defines esbuild build script and dependencies
- `esbuild.config.mjs` - esbuild configuration with gem JavaScript path resolution
- `Procfile.dev` - Defines processes for development (Rails + esbuild watch)
- `bin/dev` - Startup script for development environment

### Dependencies

```json
{
  "@hotwired/stimulus": "^3.2.2",
  "@hotwired/turbo-rails": "^8.0.0",
  "esbuild": "^0.25.0"
}
```

## Running the Dummy App

### First Time Setup

```bash
# Install JavaScript dependencies
npm install

# Build JavaScript assets
npm run build

# Setup database (if needed)
bin/rails db:migrate
```

### Start Development Server

```bash
# Start Rails server + esbuild watcher
bin/dev
```

This starts two processes:
- Rails server on `http://localhost:3000`
- esbuild watcher (auto-rebuilds on JavaScript changes)

### Visit the App

Open `http://localhost:3000` in your browser. You'll be redirected to `/admin/users`.

## Running Tests

From the gem root directory (not from spec/dummy):

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/integration/users_list_spec.rb

# Run request specs
bundle exec rspec spec/requests/

# Run system/integration specs
bundle exec rspec spec/system/
```

**Note**: JavaScript assets must be built before running tests. Run `npm run build` in the dummy app directory if tests fail with JavaScript errors.

## Structure Overview

```
spec/dummy/
├── app/
│   ├── assets/
│   │   ├── builds/              # esbuild output (gitignored)
│   │   └── config/
│   │       └── manifest.js      # Sprockets manifest
│   ├── components/              # Custom ViewComponents
│   │   └── admin/
│   │       └── user/
│   │           ├── index_page_component.rb
│   │           ├── index_page_component.html.erb
│   │           ├── show_page_component.rb
│   │           └── show_page_component.html.erb
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   └── admin/
│   │       ├── users_controller.rb    # Full CRUD with FlexiAdmin
│   │       └── comments_controller.rb # Nested resource example
│   ├── javascript/
│   │   ├── application.js             # Entry point
│   │   └── controllers/
│   │       ├── application.js         # Stimulus setup
│   │       ├── index.js               # Controller registration
│   │       └── edit_controller.js     # Custom edit mode controller
│   ├── models/
│   │   ├── application_record.rb
│   │   ├── user.rb                    # Includes FlexiAdmin concerns
│   │   └── comment.rb
│   └── views/
│       └── layouts/
│           └── application.html.erb   # Includes JS/CSS tags
├── config/
│   ├── application.rb                 # Rails + esbuild config
│   ├── database.yml                   # SQLite in-memory
│   ├── routes.rb                      # Admin namespace routes
│   └── initializers/
│       └── flexi_admin.rb             # FlexiAdmin configuration
├── db/
│   └── migrate/                       # Migrations for test schema
├── esbuild.config.mjs                 # esbuild bundler config
├── package.json                       # npm dependencies and scripts
├── Procfile.dev                       # Development processes
└── bin/
    └── dev                            # Development startup script
```

## Models

### User

Demonstrates FlexiAdmin's main features:

```ruby
class User < ApplicationRecord
  include FlexiAdmin::Models::Concerns::ApplicationResource
  include GlobalID::Identification

  has_many :comments, dependent: :destroy

  validates :full_name, :email, presence: true
  validates :email, uniqueness: true
end
```

**Fields**: full_name, email, role, user_type, personal_number, last_login_at

### Comment

Demonstrates nested resource pattern:

```ruby
class Comment < ApplicationRecord
  include FlexiAdmin::Models::Concerns::ApplicationResource
  include GlobalID::Identification

  belongs_to :user

  validates :content, presence: true
end
```

## Controllers

### Admin::UsersController

Full CRUD implementation with all FlexiAdmin features:

```ruby
class Admin::UsersController < ApplicationController
  include FlexiAdmin::Controllers::ResourcesController

  # Inherits:
  # - index, show, new, create, edit, update, destroy
  # - search, filtering, sorting, pagination
  # - bulk_action (for bulk operations)
end
```

Features:
- Search by name or email
- Filter by role
- Sort by any column
- Pagination (10, 25, 50, 100 per page)
- Bulk actions (delete, export, etc.)
- Turbo Streams for async updates

### Admin::CommentsController

Nested resource under users:

```ruby
class Admin::CommentsController < ApplicationController
  include FlexiAdmin::Controllers::ResourcesController

  # Scoped to user: /admin/users/:user_id/comments
end
```

## Custom Components

### Admin::User::IndexPageComponent

Customizes the user list page:

```ruby
class Admin::User::IndexPageComponent < FlexiAdmin::Components::Resources::IndexPageComponent
  # Uses slots to customize:
  # - Search fields
  # - Filter dropdowns
  # - Toolbar actions
  # - Table columns
end
```

### Admin::User::ShowPageComponent

Customizes the user detail page:

```ruby
class Admin::User::ShowPageComponent < FlexiAdmin::Components::Resources::ShowPageComponent
  # Custom layout for showing user details
  # Integrates with edit_controller.js for inline editing
end
```

## JavaScript

### Entry Point

`app/javascript/application.js`:

```javascript
import "@hotwired/turbo-rails"
import "./controllers"
import "flexi_admin"  // Imports gem's Stimulus controllers
```

### Custom Controllers

`app/javascript/controllers/edit_controller.js`:

A custom Stimulus controller for toggling edit mode on the user detail page. Example of how to extend FlexiAdmin with custom JavaScript.

### FlexiAdmin Controllers

The gem provides 18 Stimulus controllers that are automatically loaded:
- bulk-action
- autocomplete
- pagination
- sorting
- filter-auto-submit
- and more...

## Configuration

### FlexiAdmin Config

`config/initializers/flexi_admin.rb`:

```ruby
FlexiAdmin::Config.configure do |config|
  config.namespace = 'admin'
end
```

### Routes

`config/routes.rb`:

```ruby
Rails.application.routes.draw do
  namespace :admin do
    resources :users do
      collection do
        post :bulk_action
      end
      resources :comments
    end
  end

  root to: redirect('/admin/users')
end
```

## Test Coverage

This dummy app is used to test:

### Integration Tests
- Users list page (search, filter, sort, pagination, bulk actions)
- User detail page (view, edit, delete)
- Nested comments (CRUD within user context)

### Request Tests
- Controller actions (index, show, create, update, destroy)
- Turbo Stream responses
- Bulk action handling
- Error handling and validation

### Component Tests
- ViewComponent rendering
- Slot customization
- Context building

### System Tests
- JavaScript behavior
- Stimulus controller interactions
- Turbo navigation and updates

## Known Limitations

1. **Database**: Uses SQLite in-memory, resets between test runs
2. **Authentication**: No authentication (focused on FlexiAdmin features)
3. **Authorization**: No authorization (all actions permitted)
4. **Seed Data**: No seed data (tests create their own fixtures)

## Troubleshooting

### JavaScript not loading

```bash
# Rebuild assets
npm run build

# Check output exists
ls -la app/assets/builds/application.js
```

### Module not found: flexi_admin

Check `esbuild.config.mjs` has correct path to gem JavaScript:

```javascript
nodePaths: [
  './node_modules',
  path.resolve('../../../lib/flexi_admin/javascript')
]
```

### Stimulus controllers not registered

Open browser console and check:

```javascript
window.Stimulus.controllers
// Should list both gem and dummy app controllers
```

### Tests failing

```bash
# Rebuild JavaScript
cd spec/dummy
npm run build

# Return to gem root and run tests
cd ../..
bundle exec rspec
```

## Development Workflow

1. **Start dummy app**: `bin/dev` (from spec/dummy)
2. **Make changes** to gem code
3. **Refresh browser** to see changes
4. **Run tests** to verify: `bundle exec rspec` (from gem root)
5. **Check console** for JavaScript errors

The esbuild watcher will automatically rebuild JavaScript when gem files change.

## Adding New Features

When adding new features to FlexiAdmin:

1. **Add to gem**: Create components/controllers in gem's lib/
2. **Test in dummy**: Add routes/views to exercise new feature
3. **Write tests**: Add integration/request/component specs
4. **Verify manually**: Use bin/dev to test in browser
5. **Document**: Update README with usage examples

## Resources

- Main gem documentation: `../../README.md`
- Testing guide: `../../TESTING.md`
- CI requirements: `../../CI_REQUIREMENTS.md`
