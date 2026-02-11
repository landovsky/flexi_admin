# frozen_string_literal: true

module Admin
  module User
    module Show
      class EditFormComponent < FlexiAdmin::Components::Resource::FormComponent
        alias user resource
      end
    end
  end
end
