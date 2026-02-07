# frozen_string_literal: true

require 'capybara/rspec'
require 'selenium-webdriver'

# Register headless Chrome driver (default for CI)
Capybara.register_driver :selenium_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')  # Use new headless mode
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1400,900')
  options.add_argument('--disable-blink-features=AutomationControlled')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Register headed Chrome driver for debugging (HEADED=1)
Capybara.register_driver :selenium_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1400,900')
  options.add_argument('--disable-blink-features=AutomationControlled')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Switch driver based on environment variable
Capybara.javascript_driver = ENV['HEADED'] == '1' ? :selenium_chrome : :selenium_headless
Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }

# Enable screenshots on failure
Capybara.save_path = File.expand_path('../tmp/capybara', __dir__)

# Configure RSpec to use JavaScript driver for tests tagged with :js
RSpec.configure do |config|
  config.before(:each, type: :feature) do |example|
    if example.metadata[:js]
      Capybara.current_driver = Capybara.javascript_driver
    else
      Capybara.current_driver = :rack_test
    end
  end

  config.after(:each, type: :feature) do
    Capybara.current_driver = :rack_test
  end

  # Save screenshot on failure for JS tests
  config.after(:each, type: :feature) do |example|
    if example.metadata[:js] && example.exception
      meta = example.metadata
      filename = File.basename(meta[:file_path])
      line_number = meta[:line_number]
      screenshot_name = "#{filename}-#{line_number}-#{Time.now.to_i}.png"
      screenshot_path = File.join(Capybara.save_path, screenshot_name)

      page.save_screenshot(screenshot_path) if page.driver.browser.respond_to?(:save_screenshot)

      puts "\nScreenshot saved to: #{screenshot_path}"
    end
  end
end
