# frozen_string_literal: true

module FlexiAdmin::Components::Resources::GridView
  class GridComponent < FlexiAdmin::Components::BaseComponent
    attr_reader :resources, :title_element, :header_element, :description_element,
                :image_element, :quick_action_block, :context

    def initialize(resources, title_element, header_element, description_element, image_element, quick_action_block, context)
      @resources = resources
      @title_element = title_element
      @header_element = header_element
      @description_element = description_element
      @image_element = image_element
      @quick_action_block = quick_action_block
      @context = context
    end
  end
end
