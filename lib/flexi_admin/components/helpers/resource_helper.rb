# frozen_string_literal: true

module FlexiAdmin::Components::Helpers::ResourceHelper
  include FlexiAdmin::Components::Helpers::UrlHelper

  def autocomplete_path(action:, fields:, parent: nil)
    payload = {
      ac_action: action,
      ac_path: resource__path,
      fa_parent: parent&.gid_param,
      ac_fields: fields
    }
    path = namespaced_path('autocomplete', 'namespace', scope_plural)
    route_exists_in_main_app?(path) ? main_app.send(path, params: payload) : helpers.send(path, params: payload)
  # rescue => e
  #   binding.pry if Rails.env.development?
  end

  def datalist_path(action:, fields:, parent: nil)
    payload = {
      ac_action: action,
      ac_fields: fields
    }

    path = namespaced_path('datalist', 'namespace', scope_plural)
    route_exists_in_main_app?(path) ? main_app.send(path, params: payload) : helpers.send(path, params: payload)
  # rescue => e
  #   binding.pry if Rails.env.development?
  end

  def edit_resource_path(resource, **params)
    path = namespaced_path('edit', 'namespace', scope_singular)
    route_exists_in_main_app?(path) ? main_app.send(path, resource, params:) : helpers.send(path, resource, params:)
  # rescue => e
  #   binding.pry if Rails.env.development?
  end

  def bulk_action_path(scope, **params)
    raise 'Scope is not defined' if scope.blank?

    path = namespaced_path('bulk_action', 'namespace', scope)
    route_exists_in_main_app?(path) ? main_app.send(path, params:) : helpers.send(path, params:)
  # rescue => e
  #   binding.pry if Rails.env.development?
  end

  def resource_path(resource, **params)
    path = namespaced_path('namespace', scope_singular)
    route_exists_in_main_app?(path) ? main_app.send(path, resource, params:) : helpers.send(path, resource, params:)
  # rescue => e
  #   binding.pry if Rails.env.development?
  end

  def resource__path
    namespaced_path('namespace', scope_singular)
  # rescue => e
  #   binding.pry if Rails.env.development?
  end

  def resources_path(parent: nil, **params)
    if scope.include?('/')
      parent_key = scope.split('/').first.singularize + '_id'
      parent_id = parent&.id || params[parent_key.to_sym] || params[:id]
      params = params.merge(parent_key => parent_id) if parent_id
    end
    params = params.except(:id, :controller, :action)
    path = namespaced_path('namespace', scope_plural)
    route_exists_in_main_app?(path) ? main_app.send(path, params) : helpers.send(path, params)
  end

  def resource_input_name
    "#{scope_singular}_id"
  # rescue => e
  #   binding.pry if Rails.env.development?
  end

  def scope_plural
    scope.gsub('/', '_')
  # rescue => e
  #   binding.pry if Rails.env.development?
  end

  def scope_singular
    scope.singularize
  # rescue => e
  #   binding.pry if Rails.env.development?
  end

  def scope
    @scope ||= begin
      return context.scope if defined?(context)
      return resource.model_name.try(:plural) if defined?(resource)

      raise 'Scope is not defined'
    end
  end

  def paginate(resource, per_page: 10)
    resource.paginate(page: params[:page], per_page: per_page)
  end
end
