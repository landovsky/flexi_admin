# frozen_string_literal: true

module Admin
  module User
    class ResourcesComponent < FlexiAdmin::Components::Resources::ResourcesComponent
      self.scope = 'users'
      self.views = %w[list]
      self.includes = %w[]
    end
  end
end
