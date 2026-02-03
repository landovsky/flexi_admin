# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Debug Create', type: :request do
  it 'tests create action' do
    user_params = {
      user: {
        full_name: 'New User',
        email: 'new@example.com',
        role: 'user'
      }
    }

    initial_count = User.count

    # Try to create directly to see if it works
    test_user = User.new(full_name: 'New User', email: 'new@example.com', role: 'user')
    puts "\n=== DIRECT CREATE TEST ==="
    puts "Valid: #{test_user.valid?}"
    puts "Errors: #{test_user.errors.full_messages}" unless test_user.valid?
    puts "=== END DIRECT TEST ===\n"

    post '/admin/users', params: user_params

    puts "\n=== CREATE DEBUG ==="
    puts "Initial count: #{initial_count}"
    puts "Final count: #{User.count}"
    puts "Status: #{response.status}"
    puts "Body: #{response.body}"
    puts "=== END DEBUG ==="
  end
end
