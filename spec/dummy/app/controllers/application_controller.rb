# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Skip CSRF verification for testing - will use exception in production
  protect_from_forgery with: :exception unless Rails.env.test?
end
