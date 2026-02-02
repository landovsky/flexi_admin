# frozen_string_literal: true

require_relative "lib/flexi_admin/version"

Gem::Specification.new do |spec|
  spec.name = "flexi_admin"
  spec.version = FlexiAdmin::VERSION
  spec.authors = ["Tomas Landovsky"]
  spec.email = ["landovsky@gmail.com"]

  spec.summary = "FlexiAdmin - just another admin framework"
  spec.description = "FlexiAdmin is a flexible and extensible admin framework for Rails applications."
  spec.homepage = "https://github.com/landovsky/flexi_admin"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/landovsky/flexi_admin"
  spec.metadata["changelog_uri"] = "https://github.com/landovsky/flexi_admin/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir[
    "lib/**/*",
    "MIT-LICENSE",
    "Rakefile",
    "README.md"
  ]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "lib/flexi_admin", "lib/flexi_admin/components",
                        "lib/flexi_admin/models", "lib/flexi_admin/controllers",
                        "lib/flexi_admin/views", "lib/flexi_admin/assets",
                        "lib/flexi_admin/helpers", "lib/flexi_admin/services",
                        "lib/flexi_admin/javascript"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "actionview", ">= 7.1", "< 9"
  spec.add_dependency "activesupport", ">= 7.1", "< 9"
  spec.add_dependency "gemini-ai"
  spec.add_dependency "slim-rails"
  spec.add_dependency "view_component", "= 3.20"
  spec.add_dependency "will_paginate"
  spec.add_dependency "will_paginate-bootstrap-style"

  # Development dependencies
  spec.add_development_dependency "capybara", "~> 3.39"
  spec.add_development_dependency "database_cleaner-active_record", "~> 2.1"
  spec.add_development_dependency "factory_bot_rails", "~> 6.4"
  spec.add_development_dependency "pry-rails", "~> 0.3.10"
  spec.add_development_dependency "rails", ">= 7.1", "< 9"
  spec.add_development_dependency "rspec-rails", "~> 6.1"
  spec.add_development_dependency "selenium-webdriver"
  spec.add_development_dependency "semantic"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "sprockets-rails"
  spec.add_development_dependency "sqlite3", "~> 2.0"
  spec.add_development_dependency "puma", "~> 6.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
