# frozen_string_literal: true

module FlexiAdmin::Components::Helpers::ActionHelper
  # Context overrides the context normally given by the class including this module
  # Example - adding action button to a custom view form
  def action(action_component, disabled: true, selection_dependent: true, context: nil)
    render FlexiAdmin::Components::Resources::BulkAction::ButtonComponent.new(context || self.context,
                                                                              action_component,
                                                                              disabled:,
                                                                              selection_dependent:)
  end

  def action_button(item, action_component, hide_icon: false, **options)
    render FlexiAdmin::Components::Resources::BulkAction::RowActionButtonComponent.new(item,
                                                                                       context,
                                                                                       action_component,
                                                                                       hide_icon: hide_icon,
                                                                                       **options)
  end

  # Renders a dropdown with multiple action buttons for a single row/item
  # Use this in column blocks when you have multiple actions for an item
  # Example:
  #   = actions_dropdown(item) do |dropdown|
  #     - dropdown.with_action_button(item, context, ChangeStatus)
  #     - dropdown.with_action_button(item, context, AssignUser)
  def actions_dropdown(item, &block)
    render FlexiAdmin::Components::Resources::BulkAction::RowActionsDropdownComponent.new(item, context) do |component|
      block.call(component) if block
      component
    end
  end
end
