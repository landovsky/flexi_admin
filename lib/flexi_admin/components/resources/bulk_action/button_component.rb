# frozen_string_literal: true

class Resources::BulkAction::ButtonComponent < ViewComponent::Base
  include FlexiAdmin::Components::Helpers::UrlHelper
  include FlexiAdmin::Components::Helpers::IconHelper

  attr_reader :context, :modal_class, :disabled, :selection_dependent, :options

  def initialize(context, modal_class, disabled: true, selection_dependent: true, **options)
    @context = context
    @modal_class = modal_class
    @disabled = selection_dependent && disabled
    @selection_dependent = selection_dependent
    @options = options
  end

  def css_utility_classes
    classes = []
    classes << "disabled" if disabled
    classes << "selection-dependent" if selection_dependent
    classes.compact.join(" ")
  end

  def scoped_url_with_modal_id
    modals_path(kind: modal_class.modal_id, **context.to_params)
  end
end
