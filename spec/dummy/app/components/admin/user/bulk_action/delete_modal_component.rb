# frozen_string_literal: true

# ============================================================================
# FLEXI ADMIN EXAMPLE: Bulk Action — Delete (destructive, selection-dependent)
# ============================================================================
# Bulk actions inherit from BulkAction::ModalComponent and define:
#
#   self.class_name  — resource class name (used for path generation)
#   button 'Label', icon: 'bootstrap-icon'  — toolbar button config
#   title 'Modal Title'                     — modal dialog title
#
#   class Processor — business logic, instantiated with (resources, params)
#     def perform → returns a result struct with:
#       result:      :redirect | :success | :error
#       message:     flash message text
#       path:        redirect URL (for :redirect result)
#       redirect_to: (alias)
#       reload:      :page (to reload full page after success)
#
# The modal template (Slim) defines form content inside the modal dialog.
# Use the form DSL (same as edit forms) for inputs in the modal.
# ============================================================================

module Admin
  module User
    module BulkAction
      class DeleteModalComponent < FlexiAdmin::Components::Resources::BulkAction::ModalComponent
        self.class_name = "Admin::User"

        button "Delete", icon: "trash"
        title "Delete Users"

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

          # Performs the bulk operation and returns a result struct.
          # :redirect result navigates to path after action completes.
          def perform
            resources.destroy_all
            Result.new(
              result: :redirect,
              message: "#{resources.length} users deleted",
              path: "/admin/users"
            )
          end
        end
      end
    end
  end
end
