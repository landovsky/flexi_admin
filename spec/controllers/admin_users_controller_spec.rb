# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  it 'renders index' do
    create(:user, :balicka)

    begin
      get :index
      puts "\n=== CONTROLLER TEST ==="
      puts "Response successful: #{response.successful?}"
      puts "Status: #{response.status}"
      puts "Body: #{response.body[0..200]}"
    rescue => e
      puts "\n=== EXCEPTION IN CONTROLLER ==="
      puts "#{e.class}: #{e.message}"
      puts e.backtrace.first(15).join("\n")
      raise
    end
  end
end
