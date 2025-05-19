# frozen_string_literal: true

# Independent component.
module FlexiAdmin::Components::Resource
  class AutocompleteComponent < FlexiAdmin::Components::BaseComponent
    include FlexiAdmin::Components::Helpers::ResourceHelper

    attr_reader :resource, :disabled, :action, :parent, :fields, :required,
                :name, :html_options, :path, :width, :value,
                :disabled_empty_custom_message

    def initialize(resource = nil, scope:, fields: [:title],
                  action: :select, parent: nil, path: nil,
                  value: nil, disabled_empty_custom_message: nil, **html_options)
      @resource = resource
      @scope = scope
      @parent = parent
      @fields = fields
      @path = path
      @action = action
      @value = value

      @html_options = html_options
      @width = html_options.delete(:width)
      @required = html_options[:required]
      @style = html_options.delete(:style)
      @disabled = html_options.key?(:disabled) ? html_options[:disabled] : false
      @name = html_options[:name] || resource_input_name
      @disabled_empty_custom_message = disabled_empty_custom_message || 'žádný zdroj'

      validate_action!
    end

    def autocomplete_options
      {
        style: 'border-top-right-radius: 0.4rem; border-bottom-right-radius: 0.4rem;',
        data: { autocomplete_target: 'input',
                action: 'keyup->autocomplete#keyup focusout->autocomplete#onFocusOut',
                autocomplete_search_path: get_path,
                autocomplete_is_disabled: disabled,
                field_type: kind }.merge(html_options)
      }
    end

    private

    def icon_class
      case action
      when :input
        'bi-alphabet'
      else
        'bi-search'
      end
    end

    def select?
      action == :select
    end

    def data_list?
      action == :input
    end

    def kind
      data_list? ? :text : :autocomplete
    end

    def get_path
      return path if path.present?

      case action
      when :input
        datalist_path(action: :input, parent:, fields:)
      else
        autocomplete_path(action:, parent:, fields:)
      end
    end

    def validate_action!
      return if %i[select show input].include?(@action)

      raise "Invalid action: #{@action}"
    end
  end
end
