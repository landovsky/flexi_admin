# frozen_string_literal: true

# ============================================================================
# FLEXI ADMIN EXAMPLE: Resources Component (Ruby class)
# ============================================================================
# Configures the resource collection display. Key class-level settings:
#
#   self.scope    - Resource identifier, used for routing and Turbo frame IDs.
#                   Must match the route name (e.g. 'users' for resources :users).
#   self.views    - Available view modes: %w[list], %w[grid], or %w[list grid].
#                   First item is the default view.
#   self.includes - ActiveRecord eager-loading associations (optional).
# ============================================================================

module Admin
  module User
    class ResourcesComponent < FlexiAdmin::Components::Resources::ResourcesComponent
      self.scope = 'users'
      self.views = %w[list grid]
      self.includes = %w[comments]
    end
  end
end
