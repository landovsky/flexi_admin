# frozen_string_literal: true

module Admin
  class TestController < ::ApplicationController
    include FlexiAdmin::Controllers::ResourcesController

    def autocomplete
      @user = ::User.first
      @user_without_supervisor = ::User.new(full_name: 'New User', email: 'new@test.com')
      render Admin::Test::AutocompletePageComponent.new(
        user: @user,
        user_without_supervisor: @user_without_supervisor
      )
    end

    def autocomplete_submit
      # Handle form submission for testing
      redirect_to admin_test_autocomplete_path, notice: "Form submitted with supervisor_id: #{params[:supervisor_id]}"
    end

    def form_fields
      @user = ::User.first || ::User.new(full_name: 'Test User', email: 'test@example.com')
      @user_with_errors = ::User.new(full_name: '', email: 'invalid')
      @user_with_errors.valid? # Trigger validation to populate errors
      render Admin::Test::FormFieldsPageComponent.new(
        user: @user,
        user_with_errors: @user_with_errors,
        disabled: params[:disabled] == 'true'
      )
    end

    def form_fields_submit
      # Handle form submission for testing
      redirect_to admin_test_form_fields_path, notice: "Form submitted with params: #{params.except(:authenticity_token, :controller, :action).to_unsafe_h}"
    end

    private

    def resource_class
      ::User
    end
  end
end
