# frozen_string_literal: true

module Admin
  module Test
    class EmbeddedListPageComponent < ViewComponent::Base
      include FlexiAdmin::Components::Helpers::ResourceHelper

      attr_reader :context_params

      def initialize(context_params:, host_per_page: nil)
        @context_params = context_params
        @host_per_page = host_per_page
      end

      def call
        render Admin::User::ResourcesComponent.new(paginate(::User.order(:id), per_page: @host_per_page || WillPaginate.per_page), context_params:)
      end
    end
  end
end
