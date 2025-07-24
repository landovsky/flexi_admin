# frozen_string_literal: true

module FlexiAdmin::Components::Resources
  class IndexPageComponent < FlexiAdmin::Components::BaseComponent
    attr_reader :resources, :context_params, :scope, :title, :show_search, :subtitle

    renders_one :search
    renders_one :filter
    renders_one :actions

    def initialize(resources, context_params:, scope:, show_search: true, title: nil, subtitle: nil)
      @resources = resources
      @context_params = context_params
      @scope = scope
      @title = title
      @show_search = show_search
      @subtitle = subtitle
    end
  end
end
