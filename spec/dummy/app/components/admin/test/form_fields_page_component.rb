# frozen_string_literal: true

module Admin
  module Test
    class FormFieldsPageComponent < ViewComponent::Base
      include FlexiAdmin::Components::Resource::FormMixin
      include FlexiAdmin::Components::Helpers::ResourceHelper

      attr_reader :user, :user_with_errors

      def initialize(user:, user_with_errors:, disabled: false)
        @user = user
        @user_with_errors = user_with_errors
        @disabled = disabled
        @resource = user
      end

      def resource
        @resource
      end

      def disabled
        @disabled
      end

      def resource__path
        'admin/users'
      end

      def resource__class
        ::User
      end

      # Role options for select/button-select
      def role_options
        [
          ['User', 'user'],
          ['Admin', 'admin'],
          ['Manager', 'manager']
        ]
      end

      # Type options
      def type_options
        [
          ['Internal', 'internal'],
          ['External', 'external']
        ]
      end
    end
  end
end
