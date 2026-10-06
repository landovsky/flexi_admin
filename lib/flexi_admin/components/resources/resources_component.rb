# frozen_string_literal: true

module FlexiAdmin::Components::Resources
  class ResourcesComponent < FlexiAdmin::Components::BaseComponent
    include FlexiAdmin::Components::Helpers::ActionHelper

    attr_reader :resources, :scope, :options, :title, :context_params

    renders_one :actions
    renders_one :views

    class << self
      attr_accessor :views, :scope, :includes
    end

    def initialize(resources, context_params:, views: nil, title: nil, **options)
      @resources = resources
      @scope = self.class.scope
      @options = options
      @options[:views] = views if views.present?
      @context_params = context_params
      @title = title
    end

    def context
      @context ||= begin
        options = @options.merge(title:,
                                 views: @options[:views].presence || self.class.views)

        params = with_remembered_per_page(context_params.with_parent(options[:parent]))

        FlexiAdmin::Models::Resources::Context.new(paginated_as(resources, params.per_page), scope, params, options)
      end
    end

    private

    # A list embedded in another resource's detail page is paginated by that
    # page's `paginate` helper, whose request belongs to a different controller
    # and names no page size — so the size the user picked for this list would
    # never reach it. Read the memory here, where the list's scope is known.
    def with_remembered_per_page(params)
      return params if params.per_page.present?

      remembered = helpers.cookies[FlexiAdmin::Models::PerPageMemory.cookie_key(scope)]
      return params unless FlexiAdmin::Models::PerPageMemory.valid?(remembered)

      params.merge(per_page: remembered)
    end

    # Re-slice only a page cut at the default size: a host that paginated with
    # its own size (e.g. a picker listing everything at once) meant that size.
    def paginated_as(resources, per_page)
      return resources if per_page.blank?
      return resources unless resources.is_a?(ActiveRecord::Relation) && resources.respond_to?(:current_page)
      return resources if resources.limit_value == per_page.to_i
      return resources unless resources.limit_value == WillPaginate.per_page

      resources.paginate(page: resources.current_page, per_page: per_page.to_i)
    end
  end
end
