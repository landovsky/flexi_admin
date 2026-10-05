# frozen_string_literal: true

# ============================================================================
# FLEXI ADMIN EXAMPLE: New Form Component (Ruby class)
# ============================================================================
# Used for the "create new resource" form. Inherits FormComponent like the
# edit form but is always in editable mode (disabled: false).
#
# The parent parameter enables parent-child association: when creating a
# resource from a parent's show page, the parent is passed via context_params
# and can be encoded as a hidden field.
# ============================================================================

module Admin
  module User
    class NewFormComponent < FlexiAdmin::Components::Resource::FormComponent
      attr_reader :parent

      def initialize(resource, parent: nil)
        super(resource, disabled: false)
        @parent = parent
      end

      alias user resource
    end
  end
end
