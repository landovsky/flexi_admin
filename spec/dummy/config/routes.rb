# frozen_string_literal: true

Rails.application.routes.draw do
  # Define admin routes
  namespace :admin do
    resources :users do
      collection do
        post :bulk_action
      end
      resources :comments
    end
  end

  # Ignore favicon requests from Chrome
  get '/favicon.ico', to: proc { [204, {}, []] }

  # Root route for testing
  root to: redirect('/admin/users')
end
