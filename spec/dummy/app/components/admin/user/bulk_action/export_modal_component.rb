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
      end
    end
  end
end
