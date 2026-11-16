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

    # A detail page hosting a resource list, like an order showing its items:
    # the host paginates with the `paginate` helper, not the list's controller.
    def embedded_list
      render Admin::Test::EmbeddedListPageComponent.new(context_params:, host_per_page: params[:host_per_page]&.to_i)
    end

    def submit_button
      render Admin::Test::SubmitDemoPageComponent.new
    end

    # Answers the way the gem's ResourcesController does, picked by params[:outcome].
    def submit_button_submit
      sleep(params[:delay].to_f.clamp(0, 10))
      count = session[:submit_demo_count] = session[:submit_demo_count].to_i + 1
      counter = turbo_stream.update('submit-count', count.to_s)
      form_params = params.permit(:name, :outcome, :delay)

      case params[:outcome]
      when 'validation'
        fa_submit_result(:error)
        render turbo_stream: [counter, turbo_stream.replace('form_frame', Admin::Test::SubmitDemoFormComponent.new(
          params_in: form_params, error: 'Název je obsazený (demo validační chyba)'
        ))]
      when 'http_422'
        flash.now[:error] = FlexiAdmin::Models::Toast.new('Demo: server odpověděl 422')
        render turbo_stream: [counter, append_toasts], status: :unprocessable_entity
      else
        fa_submit_result(:success)
        render turbo_stream: [counter, turbo_stream.replace('form_frame', Admin::Test::SubmitDemoFormComponent.new(params_in: form_params))]
      end
    end

    private

    def resource_class
      ::User
    end
  end
end
