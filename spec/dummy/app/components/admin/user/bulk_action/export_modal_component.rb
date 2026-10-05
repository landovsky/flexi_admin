# frozen_string_literal: true

# ============================================================================
# FLEXI ADMIN EXAMPLE: Bulk Action — Export (non-destructive, selection-independent)
# ============================================================================
# This action is NOT selection_dependent — it operates on all/filtered resources
# regardless of checkbox selection. The button is always enabled.
#
# The modal template includes form fields (format selector) whose values are
# passed to the Processor via params.
# ============================================================================

module Admin
  module User
    module BulkAction
      class ExportModalComponent < FlexiAdmin::Components::Resources::BulkAction::ModalComponent
        self.class_name = "Admin::User"

        button "Export", icon: "download"
        title "Export Users"

        # self.path is auto-generated from class_name ("Admin::User" → "/admin/users/bulk_action").
        # Override only if your route differs from the convention.

        class Processor
          Result = Struct.new(:result, :success, :message, :redirect_to, :path, keyword_init: true)

          attr_reader :resources, :params

          def initialize(resources, params)
            @resources = resources
            @params = params
          end

          # :success result shows a toast message and stays on the page.
          def perform
            format = params[:format] || 'csv'
            Result.new(result: :success, success: true,
                       message: "#{resources.count} users exported as #{format.upcase}")
          end
        end
      end
    end
  end
end
