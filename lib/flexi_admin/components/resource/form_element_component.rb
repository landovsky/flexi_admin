# frozen_string_literal: true

module FlexiAdmin::Components::Resource
  class FormElementComponent < FlexiAdmin::Components::BaseComponent
    include FlexiAdmin::Components::Helpers::ResourceHelper

    renders_one :fields

    attr_reader :resource, :url, :css_class, :method, :html_options_except_data, :merged_data

    def initialize(resource, url:, css_class:, method: :post, **html_options)
      @resource = resource
      @url = url
      @css_class = css_class
      @method = method
      data = html_options[:data] || {}
      @merged_data = merge_data_keys(data)
      @html_options_except_data = html_options.except(:data)
    end

    def form_id
      resource.try(:identifier) || "form"
    end

    def merge_data_keys(data)
      controller = data[:controller]
      controllers = controller.present? ? [controller, "form-validation", "add-row"] : ["form-validation", "add-row"]
      data.merge(controller: controllers.join(" "))
    end
  end
end
