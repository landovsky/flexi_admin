# frozen_string_literal: true

module Admin
  module User
    module BulkAction
      # Mock modal for the submit button states; see Admin::UsersController#bulk_action for the 422 branch.
      class SubmitDemoModalComponent < FlexiAdmin::Components::Resources::BulkAction::ModalComponent
        self.class_name = "Admin::User"

        button "Test submitu", icon: "hourglass-split"
        title "Test stavů tlačítka"

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
            if params[:demo_outcome] == 'error'
              Result.new(result: :error, message: 'Demo: processor vrátil chybu')
            else
              Result.new(result: :success, message: "Demo: hotovo (#{resources.size} položek)")
            end
          end
        end
      end
    end
  end
end
