# frozen_string_literal: true

module FlexiAdmin::Components::Resources
  class PaginationComponent < FlexiAdmin::Components::BaseComponent
    LIMIT = 10

    include FlexiAdmin::Components::Helpers::ResourceHelper
    include FlexiAdmin::Components::Helpers::UrlHelper

    attr_reader :context, :per_page, :page, :limited_pagination

    def initialize(context, per_page:, page:)
      @context = context
      @resources = context.resources
      @parent = context.parent
      @per_page = per_page
      @page = page&.to_i
    end

    def render?
      paginated_resources.total_pages > 1
    end

    def limited_pages
      return (1..paginated_resources.total_pages).to_a if paginated_resources.total_pages < LIMIT

      max = paginated_resources.total_pages

      mid_range_start = if page > (LIMIT / 2) && page < (max - (LIMIT / 2))
                          page - (LIMIT / 2)
                        elsif page < (LIMIT / 2)
                          1
                        else
                          max - LIMIT
                        end

      mid_range_end = if page > (LIMIT / 2) && page < (max - (LIMIT / 2))
                        page + (LIMIT / 2)
                      elsif page < (LIMIT / 2)
                        LIMIT
                      else
                        max
                      end

      [1, (mid_range_start..mid_range_end).to_a, max].flatten.compact.uniq
    end

    def page_path(page_number)
      params = context.params
                      .merge(page: page_number, per_page:, frame: context.scope)
                      .to_params

      resources_path(parent: @parent, **params.merge)
    end

    def paginated_resources
      @resources.paginate(page:, per_page:)
    end

    def total_pages
      (resources.count / per_page.to_f).ceil
    end
  end
end
