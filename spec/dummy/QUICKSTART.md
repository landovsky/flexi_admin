# FlexiAdmin Dummy App - Quick Start Guide

## First Time Setup

```bash
cd spec/dummy
bin/setup
```

This will:
- Install npm dependencies
- Create and migrate database
- Load seed data (8 users, multiple comments)
- Build JavaScript assets

## Running the App

### Option 1: Development Mode (Recommended)
```bash
cd spec/dummy
bin/dev
```

This starts:
- Rails server on port 3000
- esbuild in watch mode (auto-rebuilds on JS changes)

Then visit: **http://localhost:3000**

### Option 2: Rails Server Only
```bash
cd spec/dummy
bin/rails server
```

Visit: **http://localhost:3000**

**Note:** JavaScript changes won't auto-rebuild. Run `npm run build` manually after JS changes.

## What You'll See

- **Home**: Redirects to `/admin/users`
- **Users List**: Search, filter by role, pagination
- **User Detail**: Click any user to see detail page
- **Comments**: Nested under users at `/admin/users/:id/comments`

## Sample Credentials

The seed data creates these users:
- jan.novak@example.com (admin)
- marie.svobodova@example.com (user)
- petr.dvorak@example.com (admin)
- And 5 more users...

## Stopping the Server

- **bin/dev**: Press `Ctrl+C` (stops both Rails and esbuild)
- **bin/rails server**: Press `Ctrl+C`

## Rebuilding Assets

If JavaScript isn't loading:
```bash
npm run build
```

## Resetting Data

```bash
bin/rails db:reset db:seed
```

## Troubleshooting

**Port already in use:**
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9
```

**JavaScript not loading:**
```bash
# Check if built
ls -lh app/assets/builds/application.js

# Rebuild if needed
npm run build
```

**Database issues:**
```bash
bin/rails db:drop db:create db:migrate db:seed
```
