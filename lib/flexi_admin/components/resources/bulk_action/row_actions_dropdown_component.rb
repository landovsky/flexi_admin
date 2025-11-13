# frozen_string_literal: true

module FlexiAdmin::Components::Resources::BulkAction
  # Component for rendering a dropdown of multiple action buttons for an individual row
  # Useful when you have multiple actions available for a single item
  class RowActionsDropdownComponent < FlexiAdmin::Components::BaseComponent
    attr_reader :item, :context

    renders_one :primary_action
    renders_many :dropdown_actions

    def initialize(item, context)
      super(nil)
      @item = item
      @context = context
    end

    def dropdown_id
      "row-actions-#{item.class.name.parameterize}-#{item.id}"
    end

    # Helper method to add an action button to the dropdown
    def action_button(modal_class, **options)
      FlexiAdmin::Components::Resources::BulkAction::RowActionButtonComponent.new(
        item,
        context,
        modal_class,
        dropdown: true,
        **options
      )
    end
  end
end
