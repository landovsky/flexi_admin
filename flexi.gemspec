# frozen_string_literal: true

require_relative "lib/flexi/version"

Gem::Specification.new do |spec|
  spec.name = "flexi"
  spec.version = Flexi::VERSION
  spec.authors = ["Tomas Landovsky"]
  spec.email = ["landovsky@gmail.com"]

  spec.summary = "Flexi - just another admin framework"
  spec.description = "Flexible Admin Framework"
  spec.homepage = "https://github.com/landovsky/flexi"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/landovsky/flexi"
  spec.metadata["changelog_uri"] = "https://github.com/landovsky/flexi/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir[
    "lib/**/*",
    "lib/tasks/**/*"
  ]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "lib/flexi", "lib/flexi/components",
                        "lib/flexi/models", "lib/flexi/controllers",
                        "lib/flexi/views", "lib/flexi/assets",
                        "lib/flexi/helpers", "lib/flexi/services",
                        "lib/flexi/javascript"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "rails", "~> 7.1.0"
  spec.add_dependency "slim-rails"
  spec.add_dependency "view_component", "~> 3.1.0"

  # Development dependencies
  spec.add_development_dependency "pry-rails", "~> 0.3.10"
  spec.add_development_dependency "rspec-rails"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end