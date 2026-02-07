require_relative 'boot'

require 'rails'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)
require 'flexi_admin'
require 'turbo-rails'

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false

    # Configure assets for esbuild
    config.assets.enabled = true
    config.assets.paths << Rails.root.join("app/assets/builds")

    # Configure paths - look in dummy directories
    config.paths['config/database'] = File.expand_path('database.yml', __dir__)
    config.paths['config/routes.rb'] = File.expand_path('routes.rb', __dir__)

    # Set up autoload paths for dummy app
    dummy_root = File.expand_path('..', __dir__)
    config.autoload_paths << "#{dummy_root}/app/controllers"
    config.autoload_paths << "#{dummy_root}/app/models"
    config.autoload_paths << "#{dummy_root}/app/components"
    config.eager_load_paths << "#{dummy_root}/app/controllers"
    config.eager_load_paths << "#{dummy_root}/app/models"
    config.eager_load_paths << "#{dummy_root}/app/components"

    # Configure GlobalID
    config.global_id = ActiveSupport::OrderedOptions.new
    config.global_id.app = 'dummy'

    # I18n configuration
    config.i18n.default_locale = :cs
    config.i18n.available_locales = [:cs, :en]
  end
end
