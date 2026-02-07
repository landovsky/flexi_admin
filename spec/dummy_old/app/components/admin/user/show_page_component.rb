# frozen_string_literal: true

module Admin
  module User
    class ShowPageComponent < ViewComponent::Base
      attr_reader :user

      def initialize(user)
        @user = user
      end
    end
  end
end
