# frozen_string_literal: true

Rails.application.routes.draw do
  # Include FlexiAdmin routes (modals, etc.)
  extend FlexiAdmin::Routes

  # Define admin routes
  namespace :admin do
    resources :users, concerns: :resourceful do
      resources :comments
    end
    # Test pages for component testing
    get 'test/autocomplete', to: 'test#autocomplete', as: :test_autocomplete
    post 'test/autocomplete_submit', to: 'test#autocomplete_submit', as: :test_autocomplete_submit
    get 'test/form_fields', to: 'test#form_fields', as: :test_form_fields
    post 'test/form_fields_submit', to: 'test#form_fields_submit', as: :test_form_fields_submit
  end

  # Ignore favicon requests from Chrome
  get '/favicon.ico', to: proc { [204, {}, []] }

  # Root route for testing
  root to: redirect('/admin/users')
end
