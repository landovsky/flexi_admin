# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)
require 'flexi_admin'

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    # Configuration for the application, engines, and railties goes here.
    config.eager_load = false

    # For compatibility with applications that use this config
    config.active_storage.service = :test if config.respond_to?(:active_storage)

    # Configure assets for test environment (needed by flexi_admin railtie)
    config.assets.enabled = true
    config.assets.paths = []
    config.assets.precompile = []

    # Configure database paths - look in dummy/config directory
    config.paths['config/database'] = File.expand_path('database.yml', __dir__)

    # Configure GlobalID
    config.global_id = ActiveSupport::OrderedOptions.new
    config.global_id.app = 'dummy'

    # I18n configuration
    config.i18n.default_locale = :cs
    config.i18n.available_locales = [:cs, :en]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
  end
end
