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

  def action_button(item, action_component, **options)
    render FlexiAdmin::Components::Resources::BulkAction::RowActionButtonComponent.new(item,
                                                                                       context,
                                                                                       action_component,
                                                                                       **options)
  end
end
