# frozen_string_literal: true

Rails.application.routes.draw do
  # Define admin routes
  namespace :admin do
    resources :users do
      resources :comments
    end
  end

  # Root route for testing
  root to: redirect('/admin/users')
end
