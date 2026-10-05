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

        # button_select_field takes plain values; display text comes from labels:
        def type_options
          %w[internal external]
        end

        def type_labels
          { 'internal' => 'Internal', 'external' => 'External' }
        end
      end
    end
  end
end
