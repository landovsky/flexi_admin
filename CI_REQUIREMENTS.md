# CI Requirements for FlexiAdmin

## Overview

With the cutover to the new dummy app that uses esbuild for JavaScript bundling, CI configuration needs to be updated to include Node.js setup and JavaScript build steps.

## Required CI Steps

### 1. Setup Node.js

Add Node.js setup before running tests:

```yaml
- name: Setup Node
  uses: actions/setup-node@v3
  with:
    node-version: '18'
```

### 2. Install JavaScript Dependencies

Install npm packages in the dummy app:

```yaml
- name: Install JavaScript dependencies
  run: |
    cd spec/dummy
    npm install
```

### 3. Build JavaScript Assets

Build esbuild assets before running tests:

```yaml
- name: Build JavaScript
  run: |
    cd spec/dummy
    npm run build
```

### 4. Run Tests

Standard RSpec test execution:

```yaml
- name: Run tests
  run: bundle exec rspec
```

## Complete GitHub Actions Example

If creating a new `.github/workflows/test.yml`:

```yaml
name: Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: '3.2'
        bundler-cache: true

    - name: Setup Node
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
        cache-dependency-path: spec/dummy/package-lock.json

    - name: Install JavaScript dependencies
      working-directory: spec/dummy
      run: npm ci

    - name: Build JavaScript
      working-directory: spec/dummy
      run: npm run build

    - name: Run tests
      run: bundle exec rspec

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      if: always()
```

## Performance Optimization

### Caching Strategies

1. **Ruby gems**: Already handled by `bundler-cache: true`
2. **Node modules**: Use `cache: 'npm'` in setup-node action
3. **Build artifacts**: Consider caching `spec/dummy/app/assets/builds/` if build is slow

### Faster Builds

```yaml
- name: Install JavaScript dependencies
  working-directory: spec/dummy
  run: npm ci  # Use ci instead of install for faster, cleaner installs
```

## Current Status

- **CI Configuration**: None exists currently
- **Required Action**: Create `.github/workflows/test.yml` with the steps above
- **Test Status**: 35/69 passing (50.7%) locally with new dummy app

## Notes

- The esbuild build step adds approximately 2-3 seconds to test setup
- npm ci is preferred over npm install in CI for reproducible builds
- Consider using GitHub Actions cache to speed up subsequent runs
- The new dummy app matches production usage patterns (esbuild + Stimulus)
