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
      end
    end
  end
end
