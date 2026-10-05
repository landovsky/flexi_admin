# frozen_string_literal: true

# ============================================================================
# FLEXI ADMIN EXAMPLE: Show Page Component (Ruby class)
# ============================================================================
# Inherits from FlexiAdmin::Components::Resource::ShowPageComponent.
# The show page renders the detail view for a single resource.
#
# Common patterns:
#   - alias the resource for readability (alias user resource)
#   - define helper methods for nested resource collections
#   - use paginate() helper for nested resource pagination
# ============================================================================

module Admin
  module User
    module Show
      class PageComponent < FlexiAdmin::Components::Resource::ShowPageComponent
        alias user resource

        # Helper for nested comments — paginated for show page display
        def comments
          paginate(user.comments.order(created_at: :desc), per_page: 5)
        end
      end
    end
  end
end
