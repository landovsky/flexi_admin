# frozen_string_literal: true

module Admin
  module User
    module BulkAction
      class ExportModalComponent < FlexiAdmin::Components::Resources::BulkAction::ModalComponent
        self.class_name = "Admin::User"

        button "Exportovat", icon: "download"
        title "Exportovat uživatele"

        def self.path
          "/admin/users/bulk_action"
        end

        class Processor
          Result = Struct.new(:result, :success, :message, :redirect_to, :path, keyword_init: true)

          attr_reader :resources, :params

          def initialize(resources, params)
            @resources = resources
            @params = params
          end

          def perform
            Result.new(result: :success, success: true, message: "#{resources.count} uživatelů exportováno")
          end
        end
      end
    end
  end
end
