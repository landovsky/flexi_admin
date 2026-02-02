# frozen_string_literal: true

module ViewComponentHelpers
  # Helper to create a valid ContextParams instance for testing
  def build_context_params(resource_class, attributes = {})
    defaults = {
      scope: resource_class.model_name.route_key,
      search: nil,
      sort_by: nil,
      sort_direction: 'asc',
      page: 1,
      per_page: 16,
      filters: {}
    }

    FlexiAdmin::ContextParams.new(defaults.merge(attributes))
  end

  # Helper to create a Context object for component testing
  def build_context(resource:, resources: nil, parent: nil, **context_params_attrs)
    resources ||= [resource].compact
    params = build_context_params(resource.class, context_params_attrs)

    FlexiAdmin::Resources::Context.new(
      resource: resource,
      resources: resources,
      parent: parent,
      params: params
    )
  end

  # Helper to render a component with standard test setup
  def render_component(component_class, **kwargs)
    render_inline(component_class.new(**kwargs))
  end
end

RSpec.configure do |config|
  config.include ViewComponentHelpers, type: :component
end
