# frozen_string_literal: true

# Requirement is handled by the model
module FlexiAdmin::Components::Resource
  class ButtonSelectComponent < FlexiAdmin::Components::BaseComponent
    attr_reader :resource, :attr_name, :options, :form, :label, :value, :html_options, :disabled

    def initialize(resource, attr_name, options, form:, label: nil, value: nil, disabled: false, labels: nil, **html_options)
      @resource = resource
      @attr_name = attr_name
      @options = options
      @form = form
      @label = label
      @value = value
      @html_options = html_options
      @disabled = disabled
      @labels = labels || {}
    end

    def label_for(option)
      return option if @labels.empty?

      @labels[option] || @labels[option.to_s] || @labels[option.to_s.to_sym] || option
    end
  end
end
