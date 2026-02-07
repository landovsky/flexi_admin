# frozen_string_literal: true

module Admin
  module Test
    class AutocompletePageComponent < ViewComponent::Base
      include FlexiAdmin::Components::Helpers::ResourceHelper

      attr_reader :user, :user_without_supervisor

      def initialize(user:, user_without_supervisor:)
        @user = user
        @user_without_supervisor = user_without_supervisor
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
