# frozen_string_literal: true

# Coverage
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
end

# Set up Rails test environment - force test mode
ENV['RAILS_ENV'] = 'test'
ENV.delete('DATABASE_URL')  # Clear any external database config
require File.expand_path('dummy/config/environment', __dir__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'capybara/rspec'
require 'view_component/test_helpers'
require 'factory_bot_rails'
require 'database_cleaner-active_record'
require 'global_id'
GlobalID.app = 'dummy'

# Configure FlexiAdmin namespace
FlexiAdmin::Config.configure do |config|
  config.namespace = 'admin'
  config.module_namespace = 'Admin'
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }

# Note: Dummy app controllers and models are autoloaded via config.autoload_paths
# defined in spec/dummy/config/application.rb

# Set up database schema for tests (database already configured in dummy app)
ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :full_name, null: false
    t.string :email, null: false
    t.string :phone
    t.string :personal_number
    t.string :role, default: 'user'
    t.string :user_type, default: 'internal'
    t.datetime :last_sign_in_at
    t.integer :sign_in_count, default: 0
    t.timestamps
  end

  add_index :users, :email, unique: true
  add_index :users, :role

  create_table :comments, force: true do |t|
    t.references :user, null: false, foreign_key: true
    t.text :content, null: false
    t.timestamps
  end
end

RSpec.configure do |config|
  config.fixture_path = nil
  config.use_transactional_fixtures = false

  # DatabaseCleaner: truncation for JS tests (Selenium can't see transactions)
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
  end

  config.before(:each) { DatabaseCleaner.start }
  config.after(:each) { DatabaseCleaner.clean }

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  # Include ViewComponent test helpers
  config.include ViewComponent::TestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component

  # Include FactoryBot syntax
  config.include FactoryBot::Syntax::Methods

  # Include Capybara DSL for integration tests
  config.include Capybara::DSL, type: :feature

  # Capybara drivers configured in spec/support/capybara.rb

  # Load I18n with flexi_admin locales
  flexi_admin_root = File.expand_path('../..', __dir__)
  I18n.load_path += Dir[File.join(flexi_admin_root, 'config', 'locales', '*.yml')]
  I18n.default_locale = :cs
  I18n.available_locales = [:cs, :en]
end
