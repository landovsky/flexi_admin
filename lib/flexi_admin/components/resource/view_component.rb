# frozen_string_literal: true

module FlexiAdmin::Components::Resource
  class ViewComponent < FlexiAdmin::Components::BaseComponent
    include FlexiAdmin::Components::Helpers::ResourceHelper
    include FlexiAdmin::Components::Helpers::ActionHelper

    attr_reader :context, :resource, :disable_buttons, :disabled_message

    renders_one :form
    renders_one :actions

    def initialize(context, disable_buttons: nil, disabled_message: nil)
      @context = context
      @resource = context.resource
      @disable_buttons = disable_buttons
      @disabled_message = disabled_message
    end

    def divider
      content_tag :div, "", class: "dropdown-divider"
    end

    def title
      resource.title
    rescue NoMethodError
      "#{resource.class.name}: title method not implemented"
    end
  end
end
