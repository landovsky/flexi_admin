# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Debug Request', type: :request do
  it 'tests basic controller rendering' do
    create(:user, :balicka)

    # Configure to show exceptions
    Rails.application.config.action_dispatch.show_exceptions = :all

    get '/admin/users'

    puts "\n=== RESPONSE INFO ==="
    puts "Status: #{response.status}"
    puts "Content-Type: #{response.content_type}"
    puts "Body length: #{response.body.length}"
    if response.body.length > 0
      puts "Body (first 1000): #{response.body[0..1000]}"
    else
      puts "Body is empty!"
    end
    puts "=== END ==="
  end
end
