# frozen_string_literal: true

module FlexiAdmin
  module Routes
    def self.extended(router)
      router.instance_eval do
        concern :flexi_admin_resourceful do
          post :bulk_action, on: :collection
          get :datalist, on: :collection
          get :autocomplete, on: :collection
        end
      end
    end
  end
end