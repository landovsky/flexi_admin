# frozen_string_literal: true

class FlexiAdmin::Components::Shared::Table::HeaderItemComponent < FlexiAdmin::Components::BaseComponent
  include FlexiAdmin::Components::Helpers::ResourceHelper

  attr_reader :column, :attr, :justify, :width, :sort_by, :context

  def initialize(column, context:)
    @column = column
    @context = context
    @justify = column.options[:justify] || :start
    @width = column.options[:width] || ""
    @attr = column.attribute
    @sort_by = column.sort_by
    @label = column.label
  end

  def label
    @label || attr.to_s.humanize
  end

  def sort_path
    if order.blank?
      resources_path(**context.params.merge)
    else
      resources_params = context.params
                                .merge(sort: sort_by, order: order)
                                .to_params

      resources_path(**resources_params.merge)
    end
  end

  def merged_classes
    [width_class, justify_class].join(" ")
  end

  def width_class
    width.present? ? "col-#{width}" : "col"
  end

  def justify_class
    case justify.to_sym
    when :start
      "justify-content-start"
    when :end
      "justify-content-end"
    else
      "justify-content-start"
    end
  end

  def sort_icon
    return "bi-arrow-up-square" if view_context.context.params[:sort].to_s != sort_by.to_s

    case view_context.context.params[:order]
    when "asc"
      "bi-arrow-up-square-fill"
    when "desc"
      "bi-arrow-down-square-fill"
    else
      "bi-arrow-up-square"
    end
  end

  def order
    # Sorting by other column, so we need to reset the order
    return "asc" if view_context.context.params[:sort].to_s != sort_by.to_s

    order = case view_context.context.params[:order]
    when "asc"
      "desc"
    when "desc"
      "default"
    when "default"
      "asc"
    else
      "asc"
    end

    order
  end
end
