# frozen_string_literal: true

# ============================================================================
# FLEXI ADMIN EXAMPLE: Bulk Action — Reset (with page reload)
# ============================================================================
# Demonstrates the reload: :page result option, which reloads the entire page
# after the action completes (useful when the action changes visible state).
#
# This action is also used as a row-level action (action_button) in the list view,
# showing how the same action component works for both bulk and single-row use.
# ============================================================================

module Admin
  module User
    module BulkAction
      class ResetModalComponent < FlexiAdmin::Components::Resources::BulkAction::ModalComponent
        self.class_name = "Admin::User"

        button "Reset", icon: "arrow-counterclockwise"
        title "Reset Users"

        # self.path auto-generated from class_name — no override needed

        class Processor
          Result = Struct.new(:result, :success, :message, :redirect_to, :path, :reload, keyword_init: true)

          attr_reader :resources, :params

          def initialize(resources, params)
            @resources = resources
            @params = params
          end

          # reload: :page triggers a full page reload after success
          def perform
            Result.new(result: :success, success: true,
                       message: "#{resources.count} users reset",
                       reload: :page)
          end
        end
      end
    end
  end
end
