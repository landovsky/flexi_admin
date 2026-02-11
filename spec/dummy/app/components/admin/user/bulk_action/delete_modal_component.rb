# frozen_string_literal: true

module Admin
  module User
    module BulkAction
      class DeleteModalComponent < FlexiAdmin::Components::Resources::BulkAction::ModalComponent
        self.class_name = "Admin::User"

        button "Smazat", icon: "trash"
        title "Smazat uživatele"

        def self.path
          "/admin/users/bulk_action"
        end

        class Processor
          Result = Struct.new(:result, :message, :redirect_to, :path, keyword_init: true)

          attr_reader :resources, :params

          def initialize(resources, params)
            @resources = resources
            @params = params
          end

          def perform
            resources.destroy_all
            Result.new(
              result: :redirect,
              message: "#{resources.length} uživatelů smazáno",
              redirect_to: nil,
              path: "/admin/users"
            )
          end
        end
      end
    end
  end
end
