# frozen_string_literal: true

module FlexiAdmin::Components::Resources
  class IndexPageComponent < FlexiAdmin::Components::BaseComponent
    attr_reader :resources, :context_params, :scope, :title, :search, :subtitle

    renders_one :search
    renders_one :actions

    def initialize(resources, context_params:, scope:, search: true, title: nil, subtitle: nil)
      @resources = resources
      @context_params = context_params
      @scope = scope
      @title = title
      @search = search
      @subtitle = subtitle
    end
  end
end
