# frozen_string_literal: true

module Admin
  module User
    module BulkAction
      class ResetModalComponent < FlexiAdmin::Components::Resources::BulkAction::ModalComponent
        self.class_name = "Admin::User"

        button "Reset", icon: "arrow-counterclockwise"
        title "Reset uživatele"

        def self.path
          "/admin/users/bulk_action"
        end

        class Processor
          Result = Struct.new(:result, :success, :message, :redirect_to, :path, :reload, keyword_init: true)

          attr_reader :resources, :params

          def initialize(resources, params)
            @resources = resources
            @params = params
          end

          def perform
            Result.new(result: :success, success: true, message: "#{resources.count} uživatelů resetováno", reload: :page)
          end
        end
      end
    end
  end
end
