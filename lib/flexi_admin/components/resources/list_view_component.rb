# frozen_string_literal: true

# Dependent component (context required).
module FlexiAdmin::Components::Resources
  class ListViewComponent < FlexiAdmin::Components::BaseComponent
    include FlexiAdmin::Components::Helpers::ResourceHelper
    include FlexiAdmin::Components::Helpers::ValueFormatter
    include FlexiAdmin::Components::Helpers::Selectable
    include FlexiAdmin::Components::Helpers::LinkHelper
    include FlexiAdmin::Components::Helpers::ActionHelper

    class Column < Struct.new(:attribute, :value, :options)
      def width
        options[:width]
      end

      def label
        options[:label]
      end

      def sortable?
        options.key?(:sortable).present? || false
      end

      def sort_by
        options[:sortable].is_a?(TrueClass) ? attribute : options[:sortable]
      end

      def formatted_value(value)
        options[:formatter].call(value)
      end
    end

    attr_reader :context, :columns, :resources, :resource

    def initialize(context)
      @context = context
      @resources = context.resources
      @columns = []
      @headers = []
      @is_selectable = false
    end

    def render?
      context.params.current_view == 'list' ||
        (context.views.first == 'list' && context.params.current_view.blank?)
    end

    def as_text(value)
      value.to_s
    end

    def as_date(value, format: nil)
      return if value.blank?

      I18n.l(value, format:)
    end

    def list_view
      yield

      table
    end

    def table
      render FlexiAdmin::Components::Resources::ListView::TableComponent.new(headers, columns, resources, context, selectable: true)
    end

    def column(attribute, options = {}, &block)
      @columns << build_column(attribute, options, &block)
    end

    def build_column(attribute, options, &block)
      options[:formatter] = format(options[:as] || :text)

      Column.new(attribute,
                block || proc { |resource| resource.send(attribute) },
                options.presence || {})
    end
  end
end
