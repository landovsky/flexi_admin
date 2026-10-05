# frozen_string_literal: true

# Requirement is handled by the model
module FlexiAdmin::Components::Resource
  class ButtonSelectComponent < FlexiAdmin::Components::BaseComponent
    attr_reader :resource, :attr_name, :options, :form, :label, :value, :html_options, :disabled

    def initialize(resource, attr_name, options, form:, label: nil, value: nil, disabled: false, labels: nil, **html_options)
      @resource = resource
      @attr_name = attr_name
      @options = options.map { |option| option.is_a?(Array) ? option.last : option }
      @form = form
      @label = label
      @value = value
      @html_options = html_options
      @disabled = disabled
      @labels = pair_labels(options).merge(labels || {})
    end

    # Accept select_field-style [label, value] pairs alongside plain values + labels:.
    def pair_labels(options)
      options.each_with_object({}) do |option, labels|
        labels[option.last.to_s] = option.first if option.is_a?(Array)
      end
    end

    def label_for(option)
      return option if @labels.empty?

      @labels[option] || @labels[option.to_s] || @labels[option.to_s.to_sym] || option
    end
  end
end
