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
    route_exists_in_main_app?(path) ? main_app.send(path, resource, **params) : helpers.send(path, resource, **params)
  # rescue => e
  #   binding.pry if Rails.env.development?
  end

  def bulk_action_path(scope, **params)
    raise 'Scope is not defined' if scope.blank?

    path = namespaced_path('bulk_action', 'namespace', scope)
    route_exists_in_main_app?(path) ? main_app.send(path, **params) : helpers.send(path, **params)
  # rescue => e
  #   binding.pry if Rails.env.development?
  end

  def resource_path(resource, **params)
    path = namespaced_path('namespace', scope_singular)
    route_exists_in_main_app?(path) ? main_app.send(path, resource, **params) : helpers.send(path, resource, **params)
  # rescue => e
  #   binding.pry if Rails.env.development?
  end

  def resource__path
    namespaced_path('namespace', scope_singular)
  # rescue => e
  #   binding.pry if Rails.env.development?
  end

  def resources_path(**params)
    path = namespaced_path('namespace', scope_plural)
    route_exists_in_main_app?(path) ? main_app.send(path, params:) : helpers.send(path, params:)
  # rescue => e
  #   binding.pry if Rails.env.development?
  end

  def resource_input_name
    "#{scope_singular}_id"
  # rescue => e
  #   binding.pry if Rails.env.development?
  end

  def scope_plural
    # Convert to snake_case first, then handle slashes
    scope.to_s.underscore.gsub('/', '_')
  # rescue => e
  #   binding.pry if Rails.env.development?
  end

  def scope_singular
    # Convert to snake_case first to handle cases like "ContactInfo" -> "contact_info"
    snake_cased = scope.to_s.underscore
    result = snake_cased.singularize
    result
  # rescue => e
  #   binding.pry if Rails.env.development?
  end

  def scope
    @scope ||= begin
      if defined?(context)
        context.scope
      elsif defined?(resource)
        resource.model_name.try(:plural)
      else
        raise 'Scope is not defined'
      end
    end
  end

  def paginate(resource, per_page: 10)
    resource.paginate(page: params[:page], per_page:)
  end
end
