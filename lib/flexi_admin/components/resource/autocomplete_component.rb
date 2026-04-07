# frozen_string_literal: true

# Independent component.
module FlexiAdmin::Components::Resource
  class AutocompleteComponent < FlexiAdmin::Components::BaseComponent
    include FlexiAdmin::Components::Helpers::ResourceHelper

    ALLOWED_ACTIONS = %i[select show input].freeze

    attr_reader :resource, :disabled, :action, :parent, :fields, :required,
                :name, :html_options, :path, :width, :value,
                :disabled_empty_custom_message, :placeholder,
                :disabled_display, :mode, :preload_count, :result_limit, :min_chars,
                :debounce_ms, :highlight_matches, :show_preload_label

    def initialize(resource = nil, scope:, fields: [:title],
                  action: :select, parent: nil, path: nil,
                  value: nil, disabled_empty_custom_message: nil,
                  disabled_display: :legacy_text,
                  target_controller: nil, placeholder: nil,
                  custom_scope: nil,
                  mode: :search, preload_count: 10, result_limit: 100,
                  min_chars: 1, debounce_ms: 200,
                  highlight_matches: false, show_preload_label: true,
                  **html_options)
      @resource = resource
      @scope = scope
      @target_controller = target_controller
      @parent = parent
      @fields = fields
      @path = path
      @action = action
      @value = value
      @custom_scope = custom_scope&.to_s

      @html_options = html_options
      @width = html_options.delete(:width)
      @required = html_options[:required]
      @style = html_options.delete(:style)
      @disabled = html_options.key?(:disabled) ? html_options[:disabled] : false

      @name = html_options[:name] || resource_input_name

      @disabled_empty_custom_message = disabled_empty_custom_message || 'žádný zdroj'
      @placeholder = placeholder || 'hledat'
      @disabled_display = disabled_display

      @mode = mode
      @preload_count = preload_count
      @result_limit = result_limit
      @min_chars = min_chars
      @debounce_ms = debounce_ms
      @highlight_matches = highlight_matches
      @show_preload_label = show_preload_label

      validate_action!
    end

    def autocomplete_options
      base_data = {
        autocomplete_target: 'input',
        action: action_string,
        autocomplete_search_path: get_path,
        autocomplete_is_disabled: disabled,
        autocomplete_mode: mode,
        autocomplete_preload_count: preload_count,
        autocomplete_result_limit: result_limit,
        autocomplete_min_chars: min_chars,
        autocomplete_debounce_ms: debounce_ms,
        autocomplete_highlight_matches: highlight_matches,
        autocomplete_show_preload_label: show_preload_label,
        field_type: kind
      }.merge(html_options)

      {
        style: 'border-top-right-radius: 0.4rem; border-bottom-right-radius: 0.4rem;',
        autocomplete: 'off',
        data: base_data
      }
    end

    def expandable_autocomplete_options
      opts = autocomplete_options
      data = opts[:data].merge(
        controller: 'expandable-field',
        action: "input->expandable-field#resize #{opts[:data][:action]}"
      )
      { data: data, **opts.except(:data) }
    end

    private

    def action_string
      base = 'keyup->autocomplete#keyup keydown->autocomplete#keydown focusout->autocomplete#onFocusOut'
      mode == :select ? "#{base} focus->autocomplete#onFocus" : base
    end

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

    def disabled_link_if_resource?
      disabled_display == :link_if_resource
    end

    def kind
      data_list? ? :text : :autocomplete
    end

    def get_path
      return path if path.present?

      case action
      when :input
        datalist_path(action: :input, parent: parent, fields: fields)
      else
        autocomplete_path(action: action, parent: parent, fields: fields, custom_scope: @custom_scope)
      end
    end

    def validate_action!
      return if ALLOWED_ACTIONS.include?(@action)

      raise "Invalid action: #{@action}"
    end
  end
end
