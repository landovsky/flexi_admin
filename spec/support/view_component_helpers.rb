# frozen_string_literal: true

module ViewComponentHelpers
  # Helper to create a valid ContextParams instance for testing
  # Uses the actual ContextParams API which expects param-mapped keys
  def build_context_params(resource_class, attributes = {})
    # Map our test attribute names to the actual fa_ prefixed param names
    param_map = {
      scope: 'fa_scope',
      page: 'fa_page',
      per_page: 'fa_per_page',
      parent: 'fa_parent',
      sort: 'fa_sort',
      order: 'fa_order',
      view: 'fa_view'
    }

    defaults = {
      'fa_scope' => resource_class.model_name.route_key,
      'fa_page' => 1,
      'fa_per_page' => 16
    }

    # Convert test attributes to actual param names
    mapped_attrs = attributes.transform_keys { |k| param_map[k.to_sym] || k.to_s }

    FlexiAdmin::Models::ContextParams.new(defaults.merge(mapped_attrs))
  end

  # Helper to create a Context object for component testing
  # Uses the actual FlexiAdmin::Models::Resources::Context API
  def build_context(resource: nil, resources: nil, parent: nil, scope: nil, **context_params_attrs)
    resources ||= resource ? [resource].compact : []
    resource_class = resource&.class || resources.first&.class || User

    # Determine scope
    scope ||= resource_class.model_name.route_key

    params = build_context_params(resource_class, context_params_attrs.merge(scope: scope))

    # Context.new takes (resources, scope, params, options)
    FlexiAdmin::Models::Resources::Context.new(
      resources,
      scope,
      params,
      { parent: parent }
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
