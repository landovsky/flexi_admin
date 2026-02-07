# frozen_string_literal: true

# Authentication test helpers for Devise/Warden
#
# Note: This file provides basic authentication helpers without requiring Devise gem.
# If Devise is added to the dummy app in the future, uncomment the relevant sections.

RSpec.configure do |config|
  # Uncomment when Devise is added:
  # config.include Devise::Test::IntegrationHelpers, type: :feature
  # config.include Devise::Test::ControllerHelpers, type: :controller
  # config.include Warden::Test::Helpers, type: :feature

  # Basic login helper for tests without Devise
  config.include Module.new {
    def login_as(user, scope: :user)
      # Simple session-based login for testing
      # In a real Devise setup, this would use Warden::Test::Helpers
      # For now, this is a no-op placeholder for when authentication is added
      @current_test_user = user
    end

    def logout
      # Reset test user
      @current_test_user = nil
    end

    def current_user
      # Helper to get current user in tests
      @current_test_user
    end
  }, type: :feature

  # Reset authentication state after each feature test
  config.after(:each, type: :feature) do
    # Uncomment when Devise/Warden is added:
    # Warden.test_reset!
    logout if respond_to?(:logout)
  end
end
