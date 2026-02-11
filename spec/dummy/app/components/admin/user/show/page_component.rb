# frozen_string_literal: true

module Admin
  module User
    module Show
      class PageComponent < FlexiAdmin::Components::Resource::ShowPageComponent
        alias user resource
      end
    end
  end
end
