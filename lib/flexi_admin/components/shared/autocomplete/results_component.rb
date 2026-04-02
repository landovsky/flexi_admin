# frozen_string_literal: true

module FlexiAdmin::Components::Shared::Autocomplete
  class ResultsComponent < FlexiAdmin::Components::BaseComponent
    attr_reader :results, :results_count, :context_params, :fields, :action, :path,
                :highlight_query, :highlight_matches, :is_preloaded, :show_preload_label

    def initialize(results:, context_params:, results_count: nil,
                   highlight_query: nil, highlight_matches: false,
                   is_preloaded: false, show_preload_label: false)
      @results = results
      @results_count = results_count
      @context_params = context_params
      @action = context_params.params["ac_action"]
      @fields = context_params.params["ac_fields"]
      @path = context_params.params["ac_path"]
      @highlight_query = highlight_query
      @highlight_matches = highlight_matches
      @is_preloaded = is_preloaded
      @show_preload_label = show_preload_label

      raise "Action not defined" unless @action
      raise "Fields not defined" unless @fields
      raise "Path is required for show action" if action == "show" && !@path
      return unless results.present? && autocomplete? && fields.any? do |field|
        !results.first.respond_to?(field.to_sym)
      end

      raise "Field #{fields} not found on #{results.first.class.name}"
    end

    # Results sorted with starts_with? matches first, then includes? matches.
    # Memoized to avoid re-sorting on multiple template calls.
    def ranked_results
      @ranked_results ||= begin
        arr = results.to_a
        if highlight_query.blank?
          arr
        else
          q_lower = highlight_query.downcase
          arr.sort_by do |result|
            display = fields.map { |f| result.try(f).to_s }.join(" ")
            display.downcase.start_with?(q_lower) ? 0 : 1
          end
        end
      end
    end

    # Returns the i18n section label for the current result set, or nil if
    # show_preload_label is false.
    def section_label
      return nil unless show_preload_label

      key = is_preloaded ? "flexi_admin.autocomplete.label.suggested" : "flexi_admin.autocomplete.label.search_results"
      I18n.t(key)
    end

    # Wraps matched substrings in <mark> tags for server-side highlighting.
    # Both the text and the query are HTML-escaped before matching so that
    # user-controlled content cannot inject HTML.
    def highlight(text, query)
      return text if !highlight_matches || query.blank?

      escaped_text    = ERB::Util.html_escape(text.to_s)
      escaped_query   = ERB::Util.html_escape(query.to_s)
      escaped_pattern = Regexp.escape(escaped_query)

      escaped_text.gsub(/#{escaped_pattern}/i, '<mark>\0</mark>').html_safe
    end

    def data_action
      case action
      when "select"
        "click->autocomplete#select"
      when "input"
        "click->autocomplete#inputValue"
      else
        ""
      end
    end

    def value(result)
      return result if datalist?

      fields.map { |field| result.try(field) }.join(" - ")
    end

    def datalist?
      action == "input"
    end

    def autocomplete?
      action != "input"
    end
  end
end
