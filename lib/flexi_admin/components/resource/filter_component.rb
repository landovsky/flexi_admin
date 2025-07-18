# frozen_string_literal: true

module FlexiAdmin::Components::Resource
  class FilterComponent < FlexiAdmin::Components::BaseComponent
    include FlexiAdmin::Components::Helpers::ResourceHelper

    attr_reader :filter_options, :filters, :params, :search_field, :field_labels

    def initialize(filter_options:, filters: true, params: {}, search_field: nil, field_labels: {})
      @filter_options = filter_options
      @filters = filters
      @search_field = search_field
      @field_labels = field_labels.with_indifferent_access
      @params =
        if params.respond_to?(:to_unsafe_h)
          params.to_unsafe_h.with_indifferent_access
        elsif params.respond_to?(:to_h)
          params.to_h.with_indifferent_access
        else
          params.with_indifferent_access
        end
    end

    def filter_configs
      return [] unless filters && filter_options.present?

      filter_options.map do |filter_name, options|
        opts, multiple = if options.is_a?(Hash)
                           [options[:options], options[:multiple]]
                         else
                           [options, false]
                         end
        opts = opts.map do |opt|
          if opt.is_a?(Array)
            { label: opt[1], value: opt[0] }
          else
            { label: opt.to_s.humanize, value: opt }
          end
        end
        {
          name: filter_name,
          label: filter_name.to_s.humanize,
          options: opts,
          multiple: multiple,
          current_value: params[filter_name],
          dropdown_id: "dropdown-#{filter_name}-#{object_id}"
        }
      end
    end
  end
end
