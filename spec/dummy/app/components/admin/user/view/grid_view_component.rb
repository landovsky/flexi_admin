# frozen_string_literal: true

# ============================================================================
# FLEXI ADMIN EXAMPLE: Grid View Component (Ruby class)
# ============================================================================
# Inherits from FlexiAdmin::Components::Resources::GridViewComponent.
# Grid views display resources as cards in a responsive grid layout.
#
# The render? method auto-checks context.params.current_view to decide
# whether to render (only renders when view mode is "grid").
# ============================================================================

module Admin
  module User
    module View
      class GridViewComponent < FlexiAdmin::Components::Resources::GridViewComponent
      end
    end
  end
end
