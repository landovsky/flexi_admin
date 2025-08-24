# frozen_string_literal: true

# with single field (inline: false)
# form-row
#   col-12 col-md-3
#     label
#   col-12 col-md-9
#     field-wrapper
#       field
#       validation-error (if resource.errors[attr_name].present?)

# with multiple fields (inline: true)
# form-row
#   col-12 col-md-3
#     label
#   col-12 col-md-9 inline-field-wrapper
#     field-wrapper
#       field
#       validation-error (if resource.errors[attr_name].present?)
#     field-wrapper
#       field
#       validation-error (if resource.errors[attr_name].present?)

module FlexiAdmin::Components::Resource
  module FormMixin
    include FlexiAdmin::Components::Helpers::ResourceHelper

    attr_reader :resource, :disabled, :inline, :parent_resource

    # Form does not render; fields do.
    def form(url: resource_path(resource), css_class: 'myForm section', method: :patch, **html_options, &block)
      render FlexiAdmin::Components::Resource::FormElementComponent.new(resource, url:, css_class:, method:, **html_options) do |component|
        component.with_fields do
          capture(&block)
        end
      end
    end

    def select_field(attr_name, options:, label: nil, value: nil, **html_options)
      field = render_select(attr_name, value:, options:, **html_options)
      field_wrapper = render_field_wrapper(field, attr_name)

      inline ? field_wrapper : render_form_row(attr_name, field_wrapper, label:, required: html_options[:required])
    end

    def button_select_field(attr_name, options:, label: nil, value: nil, **html_options)
      field = render_button_select(attr_name, options:, value:, disabled:, **html_options)
      field_wrapper = render_field_wrapper(field, attr_name)

      inline ? field_wrapper : render_form_row(attr_name, field_wrapper, label:, required: html_options[:required])
    end

    def text_field(attr_name, label: nil, value: nil, **html_options)
      field = text_field_tag(attr_name, value:, **html_options)
      field_wrapper = render_field_wrapper(field, attr_name)

      inline ? field_wrapper : render_form_row(attr_name, field_wrapper, label:, required: html_options[:required])
    end

    def text_field_tag(attr_name, value: nil, **html_options)
      render_standard_field(:text, attr_name, value, html_options)
    end

    def number_field(attr_name, label: nil, value: nil, step: 0.01, **html_options)
      field = render_standard_field(:number, attr_name, value, html_options.merge(step: step.to_s))
      field_wrapper = render_field_wrapper(field, attr_name)

      inline ? field_wrapper : render_form_row(attr_name, field_wrapper, label:, required: html_options[:required])
    end

    def checkbox_field(attr_name, label: nil, checked: nil, **html_options)
      checkbox = checkbox_field_tag(attr_name, checked:, **html_options)
      field_wrapper = render_field_wrapper(checkbox, attr_name)

      inline ? field_wrapper : render_form_row(attr_name, field_wrapper, label:, required: html_options[:required])
    end

    def checkbox_field_tag(attr_name, checked: nil, **html_options)
      val = checked.is_a?(Proc) ? checked.call : resource.try(attr_name) || checked
      hidden__field = hidden_field(attr_name, value: 0)

      options = {
        type: 'checkbox',
        name: attr_name,
        class: 'form-check-input',
        value: 1,
        checked: val,
        disabled:
      }.merge(html_options)

      checkbox = content_tag(:input, nil, options)

      hidden__field + checkbox
    end

    def hidden_field(attr_name, value: nil, **html_options)
      html_options = { type: 'hidden', name: attr_name, value: }.merge(html_options)
      content_tag(:input, nil, html_options)
    end

    def date_field(attr_name, label: nil, value: nil, **html_options)
      field = render_standard_field(:date, attr_name, value, html_options.merge(style: 'max-width: 180px;'))
      field_wrapper = render_field_wrapper(field, attr_name)

      inline ? field_wrapper : render_form_row(attr_name, field_wrapper, label:, required: html_options[:required])
    end

    def datetime_field(attr_name, label: nil, value: nil, **html_options)
      field = render_standard_field(:datetime, attr_name, value, html_options.merge(style: 'max-width: 180px;'))
      field_wrapper = render_field_wrapper(field, attr_name)

      inline ? field_wrapper : render_form_row(attr_name, field_wrapper, label:, required: html_options[:required])
    end

    # Trix field
    def html_field(attr_name, label: nil, value: nil, **html_options)
      custom_field(FlexiAdmin::Components::Shared::TrixComponent.new(attr_name:, value:, disabled:), label:, **html_options)
    end

    def header(label, description: nil)
      header_and_description = []
      header_and_description << content_tag(:div, class: 'header') { label }
      header_and_description << content_tag(:div, class: 'description') { description } if description.present?

      content_tag(:div, class: 'form-row d-flex flex-column gap-2') do
        concat content_tag(:div, class: 'col-12') { header_and_description.join.html_safe }
      end
    end

    def custom_field(view_component_instance, label: nil, **html_options, &block)
      label ||= view_component_instance.class.name.demodulize.humanize unless label == false
      value = block_given? ? capture(&block) : view_component_instance

      render_custom_field(view_component_instance, label, html_options, value)
    end

    def submit(label = 'Uložit', cancel_button: true, cancel_button_url: nil, icon: nil, classes: '')
      submit_button = if icon.present?
        helpers.content_tag(:button, class: 'btn btn-primary ' + classes, disabled: disabled) do
          content = []
          content << helpers.content_tag(:i, '', class: "bi bi-#{icon} me-2")
          content << label
          content.join.html_safe
        end
      else
        helpers.submit_tag(label, class: 'btn btn-primary ' + classes, disabled:)
      end

      if cancel_button
        cancel_btn_path = cancel_button_url || edit_resource_path(resource, fa_form_disabled: true)
        cancel_btn = content_tag(:button, 'Zrušit', class: 'btn btn-outline-secondary',
                                                    disabled:,
                                                    data: { controller: 'form',
                                                            action: 'click->form#disable',
                                                            'form-resource-path-value': cancel_btn_path })
      end

      content_tag(:div, class: 'form-row d-flex gap-3') do
        concat submit_button
        concat cancel_btn if cancel_button
      end
    end

    def with_resource(resource)
      previous_resource = @resource
      @resource = resource
      yield
    ensure
      @resource = previous_resource
    end

    private

    def render_standard_field(type, attr_name, value, html_options)
      val = value.is_a?(Proc) ? value.call : resource.try(attr_name) || value
      data = {
        action: 'blur->form-validation#handleInvalid keyup->form-validation#handleInvalid'
      }
      merge_model_error!(data, attr_name) unless type == :submit

      content = []
      input_classes = 'form-control'
      input_classes += ' is-invalid' if resource.present? && attr_name.present? && resource.errors[attr_name].present?

      if type != :submit
        content << content_tag(:input, nil,
                              {
                                type:,
                                name: attr_name,
                                value: val,
                                class: input_classes,
                                data:,
                                disabled: html_options[:disabled] || disabled
                              }.merge(html_options.except(:disabled)))
      end

      content.join.html_safe
    end

    def render_field_wrapper(field, attr_name)
      content_tag(:div, class: inline ? 'inline-field' : 'field-wrapper') do
        content = []
        content << field
        if resource.present? && attr_name.present?
          content << content_tag(:div, class: 'invalid-feedback') do
            resource.errors[attr_name].join(' ')
          end
        end

        content.join.html_safe
      end
    end

    def render_select(attr_name, options:, value: nil, **html_options)
      data = {
        action: 'blur->form-validation#handleInvalid change->form-validation#handleInvalid'
      }
      merge_model_error!(data, attr_name)

      selected = value.is_a?(Proc) ? value.call : resource.try(attr_name) || value

      content = []
      content << content_tag(:select,
                              {
                                name: attr_name,
                                class: 'form-select',
                                data: data,
                                disabled:
                              }.merge(html_options)) do
        options_for_select(options, selected: selected, disabled: 'disabled')
      end
      if resource.present? && attr_name.present?
        content << content_tag(:div, class: 'invalid-feedback') do
          resource.errors[attr_name].join(' ')
        end
      end

      content.join.html_safe
    end

    def field(attr_name, label: nil, inline: false, **html_options, &block)
      label ||= attr_name.to_s.humanize unless label == false
      @inline = inline
      content = capture(&block)

      render_form_row(attr_name, content, label:, **html_options)
    end

    def render_button_select(attr_name, options:, value: nil, resource: nil, **html_options)
      res = resource.present? ? resource : @resource
      val = value.is_a?(Proc) ? value.call : res.try(attr_name) || value

      render(FlexiAdmin::Components::Resource::ButtonSelectComponent.new(res,
                                                                         attr_name,
                                                                         options,
                                                                         disabled:,
                                                                         form: @form,
                                                                         value: val,
                                                                         **html_options))
    end

    def render_form_row(attr_name, field_html, label:, required: false, **html_options)
      label ||= attr_name.to_s.humanize unless label == false

      content_tag(:div, html_options.merge(class: 'form-row')) do
        lbl = label
        lbl += ' *' if required && !disabled
        concat content_tag(:div, class: 'col-12 col-md-3') { label_tag(attr_name, lbl) } unless label == false
        concat content_tag(:div, class: inline ? 'col-12 col-md-9 inline-field-wrapper' : 'col-12 col-md-9') {
                field_html
              }
      end
    end

    def render_custom_field(view_component_instance, label, html_options, _value)
      content_tag(:div, html_options.merge(class: 'form-row')) do
        unless label == false
          concat content_tag(:div, class: 'col-12 col-md-3') {
                  label_tag('autocomplete', label)
                }
        end
        concat content_tag(:div, class: 'col-12 col-md-9') { render view_component_instance }
      end
    end

    def merge_model_error!(data, attr_name)
      return if resource.blank?
      return if attr_name.blank?

      data.merge!(validation_error: resource.errors[attr_name].join(' ')) if resource.errors.present?
    end
  end
end