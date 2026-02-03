# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Debug Test', type: :feature do
  it 'shows what is rendered' do
    create(:user, :balicka)

    # Test using request spec approach instead
    get '/admin/users'

    puts "\n=== RESPONSE INFO ==="
    puts "Status: #{response.status}"
    puts "Content-Type: #{response.content_type}"
    puts "Body length: #{response.body.length}"
    puts "Body: #{response.body[0..500]}"
    puts "=== END ==="
  end
end
