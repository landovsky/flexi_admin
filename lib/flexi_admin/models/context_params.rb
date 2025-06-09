# frozen_string_literal: true

module FlexiAdmin::Models
  class ContextParams
    MAP = {
      scope: 'fa_scope',
      page: 'fa_page',
      per_page: 'fa_per_page',
      parent: 'fa_parent',
      frame: 'fa_frame', # target turbolinks frame
      sort: 'fa_sort',
      order: 'fa_order',
      form_disabled: 'fa_form_disabled',
      view: 'fa_view',
      ac_action: 'ac_action', # autocomplete action
      ac_fields: { 'ac_fields': [] }, # autocomplete result fields
      ac_path: 'ac_path' # autocomplete path for opening resource in new window
    }

    def self.permitted_params_keys
      MAP.values
    end

    def self.permitted_keys
      MAP.keys.map(&:to_sym)
    end

    def self.params_map
      MAP.each_with_object({}) do |(key, value), acc|
        acc[key] = value.is_a?(Hash) ? value.keys.first.to_s : value
      end
    end

    attr_reader :params

    def initialize(params)
      @params = params.to_h.with_indifferent_access.each_with_object({}) do |(key, value), acc|
        acc[self.class.params_map.invert[key.to_s]] = value
      end.with_indifferent_access
    end

    def [](key)
      @params[key]
    end

    def merge(params)
      new_params = @params.dup.merge(params.to_h.with_indifferent_access)

      if params.keys.any? { |key| !self.class.permitted_keys.include?(key.to_sym) }
        msg = "ContextParams: invalid params: "
        msg += params.keys.select { |key| !self.class.permitted_keys.include?(key.to_sym) }.join(", ")
        Rails.logger.warn msg
      end

      new_params = new_params.transform_keys { |key| self.class.params_map[key.to_sym] || key.to_sym }

      self.class.new(new_params)
    end

    def with_parent(parent_instance)
      return self if parent_instance.blank?

      merge(parent: parent_instance.gid_param)
    end

    def with_parent!(parent_instance)
      params[:parent] = parent_instance.gid_param
      self
    end

    def except(*keys)
      new_params = @params.dup.except(*keys)
      new_params = new_params.transform_keys { |key| self.class.params_map.invert[key.to_s] }
      self.class.new(new_params)
    end

    def to_params
      self.class.params_map.map { |k, v| [v, params[k]] }
          .reject { |_k, v| v.blank? }.to_h
    end

    def to_path(path)
      path + "?" + to_params.to_query
    end

    def parent
      params[:parent]
    end

    def per_page
      params[:per_page]
    end

    def page
      params[:page] || 1
    end

    def frame
      params[:frame] || '_top'
    end

    # Not sure if this is needed
    def scope
      params[:scope]
    end

    def form_disabled
      params[:form_disabled] || false
    end

    def current_view
      params[:view]
    end

    def pagination
      { page:, per_page: }
    end

    def sort
      params[:sort]
    end

    def order
      params[:order]
    end
  end
end
