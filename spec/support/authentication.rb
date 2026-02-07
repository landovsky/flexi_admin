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
      if respond_to?(:visit)
        # Feature tests - set session via Rails
        page.driver.post('/test_login', { user_id: user.id }.to_json, {
          'CONTENT_TYPE' => 'application/json'
        })
      else
        # Controller tests - set session directly
        session[:user_id] = user.id if respond_to?(:session)
      end
    end

    def logout
      if respond_to?(:visit)
        page.driver.post('/test_logout')
      else
        session.delete(:user_id) if respond_to?(:session)
      end
    end

    def current_user
      # Helper to get current user in tests
      User.find_by(id: session[:user_id]) if respond_to?(:session)
    end
  }, type: :feature

  # Reset authentication state after each feature test
  config.after(:each, type: :feature) do
    # Uncomment when Devise/Warden is added:
    # Warden.test_reset!
    logout if respond_to?(:logout)
  end
end
