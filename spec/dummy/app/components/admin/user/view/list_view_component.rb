# frozen_string_literal: true

# ============================================================================
# FLEXI ADMIN EXAMPLE: List View Component (Ruby class)
# ============================================================================
# Inherits from FlexiAdmin::Components::Resources::ListViewComponent.
# The Ruby class can define helper methods used in the Slim template.
# Column definitions and layout live in the Slim template.
#
# Built-in helpers: navigate_to, as_text, as_date, action_button, actions_dropdown.
# ============================================================================

module Admin
  module User
    module View
      class ListViewComponent < FlexiAdmin::Components::Resources::ListViewComponent
        # Custom helper — use in template blocks for custom column rendering
        def role_badge(role)
          css = role == 'admin' ? 'bg-primary' : 'bg-secondary'
          content_tag(:span, role, class: "badge #{css}")
        end
      end
    end
  end
end
