# Agent Instructions

## Project Overview

**FlexiAdmin** is a Rails engine providing an admin interface framework with ViewComponent-based architecture, Stimulus controllers, and Turbo Stream integration. The `spec/dummy` app serves as both a test harness and reference implementation.

## Task Management

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
```

### Workflow

1. Check `bd ready` for available issues (no blockers)
2. Claim with `bd update <id> --status in_progress`
3. Complete work and commit changes
4. Close with `bd close <id> --reason="description"`
5. Run `bd sync` before ending session

## Artifacts Registry

This project maintains a registry of documentation artifacts at **`artifacts/registry.json`**.

### How to Use the Registry

1. **Read `artifacts/registry.json`** at the start of every task
2. **Read all `"usage": "always"` artifacts** immediately - these contain core project conventions
3. **Scan `"usage": "decide"` artifacts** by their `description` field - read any that are relevant to your current task
4. **Follow the conventions** documented in artifacts when writing or modifying code

### When to Consult the Registry

- Starting work on a new feature or bug fix
- Working with unfamiliar parts of the codebase
- Writing or modifying tests (especially integration/feature tests)
- Implementing ViewComponents or Stimulus controllers
- Making architectural decisions about the gem or dummy app

### Registry Structure

Each artifact entry contains:
```json
{
  "filename": "path/to/artifact.md",
  "description": "Brief description of what the artifact covers",
  "usage": "always" | "decide"
}
```

**Usage field:**
- **`always`** - Must be read before any work (e.g., project overview, core conventions)
- **`decide`** - Read when the artifact is relevant to your current task (e.g., testing conventions when writing tests)

### Maintaining the Registry

When you create new documentation or discover patterns worth preserving:

1. Write the artifact to `artifacts/` (or appropriate location)
2. Add an entry to `artifacts/registry.json` with a descriptive `description` and correct `usage` level
3. Keep descriptions concise but specific enough for agents to decide relevance from the description alone

## Project Structure

```
flexi_admin_/
├── lib/flexi_admin/              # Main gem code
│   ├── components/               # ViewComponents
│   ├── controllers/              # Controller concerns
│   └── ...
├── spec/
│   ├── dummy/                    # Test Rails app
│   │   ├── app/
│   │   │   ├── components/       # Dummy app components (examples)
│   │   │   ├── controllers/      # Dummy app controllers
│   │   │   ├── javascript/       # Stimulus controllers
│   │   │   ├── models/           # Test models
│   │   │   └── views/            # Test views
│   │   └── config/
│   ├── integration/              # Feature/integration tests
│   ├── support/                  # Test helpers, matchers, shared examples
│   ├── factories/                # FactoryBot factories
│   └── rails_helper.rb           # RSpec configuration
└── artifacts/                    # Documentation artifacts
```

## Development Guidelines

### Testing

- All new features require tests
- Use `js: true` for feature tests that interact with Stimulus controllers
- Leverage custom matchers in `spec/support/matchers/`
- Use shared examples in `spec/support/shared_examples/`
- Run with `HEADED=1` to debug in visible browser

### ViewComponents

- Components live in `lib/flexi_admin/components/` for the gem
- Example implementations go in `spec/dummy/app/components/`
- Use slots for flexible composition
- Test components with component specs

### Stimulus Controllers

- Dummy app controllers: `spec/dummy/app/javascript/controllers/`
- Register in `spec/dummy/app/javascript/controllers/index.js`
- Use naming convention: `admin--user-form` → `admin/user_form_controller.js`
- Test with integration specs (js: true)

### Turbo Streams

- Controllers should respond to `format.turbo_stream`
- Return arrays of turbo stream actions for multiple updates
- Include toast notifications for user feedback
- Test with integration specs checking for in-place updates

### Code Style

- Follow existing patterns in the codebase
- Use `frozen_string_literal: true` pragma
- Keep components focused and single-purpose
- Document complex logic with comments

### Git Workflow

1. Work on feature branches (e.g., `feat/cutover-to-new-dummy`)
2. Commit frequently with descriptive messages
3. Use conventional commit format: `feat:`, `fix:`, `chore:`, etc.
4. Add `Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>` to commit messages
5. Run `bd sync` to sync beads with git
6. Push to remote regularly

## Common Tasks

### Running Tests

```bash
# All tests
bundle exec rspec

# Specific file
bundle exec rspec spec/integration/users_list_spec.rb

# Specific line
bundle exec rspec spec/integration/users_list_spec.rb:15

# With visible browser
HEADED=1 bundle exec rspec spec/integration/users_list_spec.rb

# With documentation format
bundle exec rspec --format documentation
```

### Building JavaScript

```bash
cd spec/dummy
npm run build          # Build once
npm run build:watch    # Build on file changes
```

### Starting Dummy App Server

```bash
cd spec/dummy
bin/rails server
# Visit http://localhost:5000/admin/users
```

### Creating Factories

```bash
# Add to spec/factories/
# Use traits for variations
# Keep realistic data
```

### Debugging Failed Tests

1. Check screenshot in `spec/tmp/capybara/` (for JS tests)
2. Run with `HEADED=1` to watch browser
3. Add `binding.pry` to pause execution
4. Check `page.text` or `page.all('.selector')`
5. Verify component rendered: `page.has_css?('.component-class')`

## Session Close Checklist

Before saying "done" or "complete":

```
[ ] git status              # Check what changed
[ ] git add <files>         # Stage code changes
[ ] bd sync                 # Commit beads changes
[ ] git commit -m "..."     # Commit code with Co-Authored-By
[ ] bd sync                 # Commit any new beads changes
[ ] git push                # Push to remote
```

**Never skip this.** Work is not done until pushed.
