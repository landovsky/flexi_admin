# frozen_string_literal: true

# ============================================================================
# FLEXI ADMIN EXAMPLE: Edit Form Component (Ruby class)
# ============================================================================
# Inherits from FlexiAdmin::Components::Resource::FormComponent which includes
# FormMixin — the DSL for building forms.
#
# The form respects CanCan abilities when available (disabled if user can't update).
# The `disabled` state is also toggled by the edit button on the show page.
#
# Define helper methods here for dynamic select options, computed values, etc.
# ============================================================================

module Admin
  module User
    module Show
      class EditFormComponent < FlexiAdmin::Components::Resource::FormComponent
        alias user resource

        def role_options
          [%w[User user], %w[Admin admin]]
        end

        def type_options
          [%w[Internal internal], %w[External external]]
        end
      end
    end
  end
end
