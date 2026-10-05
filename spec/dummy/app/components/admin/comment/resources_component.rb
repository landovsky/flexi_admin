# frozen_string_literal: true

# ============================================================================
# FLEXI ADMIN EXAMPLE: Nested Resource — Comment ResourcesComponent
# ============================================================================
# This is a minimal nested resource used on the User show page.
# When rendered with parent: user, the context encodes the parent's GlobalID
# so that create/bulk actions know the association.
# ============================================================================

module Admin
  module Comment
    class ResourcesComponent < FlexiAdmin::Components::Resources::ResourcesComponent
      self.scope = 'comments'
      self.views = %w[list]
    end
  end
end
