# frozen_string_literal: true

module FlexiAdmin::Models::Resources
  class Context
    attr_reader :resources, :scope, :params, :options

    def scope_id
      scope&.tr('/', '_')
    end

    def initialize(resources, scope, params, options)
      @resources = resources
      @scope = scope
      @params = params
      @options = options
    end

    def resource
      resources
    end

    def self.build(resource: nil, scope: nil, params: FlexiAdmin::Models::ContextParams.new({}), **options)
      new(resource, scope, params, options)
    end

    def self.from_params(context_params, resources = nil)
      parent = load_parent(context_params)

      new(
        resources,
        context_params.scope,
        context_params,
        {}.merge(parent:)
      )
    end

    def self.load_parent(context_params)
      return nil if context_params.parent.blank?

      gid = URI.decode_www_form_component(context_params.parent)

      GlobalID::Locator.locate(gid)
    end

    def views
      options[:views] || %w[list]
    end

    def paginate?
      options.key?(:paginate) || true
    end

    def parent
      options[:parent]
    end

    def to_params
      params.merge(scope:)
            .with_parent(parent)
            .to_params
    end
  end
end