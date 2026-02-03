# frozen_string_literal: true

require 'capybara/rspec'
require 'selenium-webdriver'

# Configure Capybara for JavaScript testing
Capybara.register_driver :selenium_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1400,900')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :selenium_headless
Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }

# Configure RSpec to use JavaScript driver for tests tagged with :js
RSpec.configure do |config|
  config.before(:each, type: :feature) do |example|
    if example.metadata[:js]
      Capybara.current_driver = :selenium_headless
    else
      Capybara.current_driver = :rack_test
    end
  end

  config.after(:each, type: :feature) do
    Capybara.current_driver = :rack_test
  end
end
