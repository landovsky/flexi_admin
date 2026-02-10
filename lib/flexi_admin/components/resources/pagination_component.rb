# frozen_string_literal: true

class FlexiAdmin::Components::Resources::PaginationComponent < FlexiAdmin::Components::BaseComponent
  MAX_PAGES_TO_SHOW_IN_PAGINATOR = 10

  include FlexiAdmin::Components::Helpers::ResourceHelper
  include FlexiAdmin::Components::Helpers::UrlHelper

  attr_reader :context, :per_page, :page, :limited_pagination

  def initialize(context, per_page:, page:)
    super()
    @context = context
    @resources = context.resources
    @parent = context.parent
    @per_page = per_page
    @page = page&.to_i
  end

  def limited_pages
    if paginated_resources.total_pages < MAX_PAGES_TO_SHOW_IN_PAGINATOR
      return (1..paginated_resources.total_pages).to_a
    end

    max = paginated_resources.total_pages

    mid_range_start = if page > (MAX_PAGES_TO_SHOW_IN_PAGINATOR / 2) && page < (max - (MAX_PAGES_TO_SHOW_IN_PAGINATOR / 2))
                        page - (MAX_PAGES_TO_SHOW_IN_PAGINATOR / 2)
                      elsif page < (MAX_PAGES_TO_SHOW_IN_PAGINATOR / 2)
                        1
                      else
                        max - MAX_PAGES_TO_SHOW_IN_PAGINATOR
                      end

    mid_range_end = if page > (MAX_PAGES_TO_SHOW_IN_PAGINATOR / 2) && page < (max - (MAX_PAGES_TO_SHOW_IN_PAGINATOR / 2))
                      page + (MAX_PAGES_TO_SHOW_IN_PAGINATOR / 2)
                    elsif page < (MAX_PAGES_TO_SHOW_IN_PAGINATOR / 2)
                      MAX_PAGES_TO_SHOW_IN_PAGINATOR
                    else
                      max
                    end

    [1, (mid_range_start..mid_range_end).to_a, max].flatten.compact.uniq
  end

  def page_path(page_number)
    params = context.params
                    .merge(page: page_number, per_page: per_page, frame: context.scope)
                    .to_params

    resources_path(**params.merge)
  end

  def per_page_path(new_per_page)
    params = context.params
                    .merge(page: 1, per_page: new_per_page, frame: context.scope)
                    .to_params

    resources_path(**params.merge)
  end

  def paginated_resources
    @resources.paginate(page: page, per_page: per_page)
  end

  def total_pages
    (resources.count / per_page.to_f).ceil
  end
end
