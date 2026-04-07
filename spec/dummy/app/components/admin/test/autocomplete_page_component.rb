# frozen_string_literal: true

module Admin
  module Test
    class AutocompletePageComponent < ViewComponent::Base
      include FlexiAdmin::Components::Helpers::ResourceHelper

      attr_reader :user, :user_without_supervisor, :input_mode_user

      def initialize(user:, user_without_supervisor:, input_mode_user:)
        @user = user
        @user_without_supervisor = user_without_supervisor
        @input_mode_user = input_mode_user
      end

      def resource__path
        'admin/users'
      end

      def resource__class
        ::User
      end
    end
  end
end
