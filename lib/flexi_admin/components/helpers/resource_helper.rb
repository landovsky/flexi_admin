# frozen_string_literal: true

module FlexiAdmin::Components::Helpers::ResourceHelper
  include FlexiAdmin::Components::Helpers::UrlHelper

  def autocomplete_path(action:, fields:, parent: nil, custom_scope: nil)
    payload = {
      ac_action: action,
      ac_path: resource__path,
      fa_parent: parent&.gid_param,
      ac_fields: fields
    }

    payload[:fa_custom_scope] = custom_scope if custom_scope.present?

    path = namespaced_path("autocomplete", "namespace", scope_plural)
    route_exists_in_main_app?(path) ? main_app.send(path, params: payload) : helpers.send(path, params: payload)
    # rescue => e
    #   binding.pry if Rails.env.development?
  end

  def datalist_path(action:, fields:, parent: nil)
    payload = {
      ac_action: action,
      ac_fields: fields
    }

    path = namespaced_path("datalist", "namespace", scope_plural)
    route_exists_in_main_app?(path) ? main_app.send(path, params: payload) : helpers.send(path, params: payload)
    # rescue => e
    #   binding.pry if Rails.env.development?
  end

  def edit_resource_path(resource, **params)
    path = namespaced_path("edit", "namespace", scope_singular)
    if route_exists_in_main_app?(path)
      main_app.send(path, resource,
                    params: params)
    else
      helpers.send(path, resource, params: params)
    end
    # rescue => e
    #   binding.pry if Rails.env.development?
  end

  def bulk_action_path(scope, **params)
    raise "Scope is not defined" if scope.blank?

    path = namespaced_path("bulk_action", "namespace", scope)
    route_exists_in_main_app?(path) ? main_app.send(path, params: params) : helpers.send(path, params: params)
    # rescue => e
    #   binding.pry if Rails.env.development?
  end

  def resource_path(resource, **params)
    path = namespaced_path("namespace", scope_singular)
    if route_exists_in_main_app?(path)
      main_app.send(path, resource,
                    params: params)
    elsif (nested_path, parent_id = nested_route_for_parent(scope_singular, params))
      main_app.send(nested_path, parent_id, resource, params: params)
    else
      helpers.send(path, resource, params: params)
    end
    # rescue => e
    #   binding.pry if Rails.env.development?
  end

  def resource__path
    namespaced_path("namespace", scope_singular)
    # rescue => e
    #   binding.pry if Rails.env.development?
  end

  def resources_path(**params)
    path = namespaced_path("namespace", scope_plural)
    if route_exists_in_main_app?(path)
      main_app.send(path, params: params)
    elsif (nested_path, parent_id = nested_route_for_parent(scope_plural, params))
      main_app.send(nested_path, parent_id, params: params)
    else
      helpers.send(path, params: params)
    end
    # rescue => e
    #   binding.pry if Rails.env.development?
  end

  def resource_input_name
    "#{scope_singular}_id"
    # rescue => e
    #   binding.pry if Rails.env.development?
  end

  def scope_plural
    if instance_variable_defined?(:@target_controller) && @target_controller.present?
      @target_controller.to_s.underscore.gsub("/", "_")
    elsif instance_variable_defined?(:@name) && @name.present?
      field_name = @name.to_s.gsub(/_id$/, "")

      base_name = field_name.gsub(/^(primary_|secondary_|main_|default_)/, "")

      base_name.pluralize
    else
      unless defined?(scope) && !scope.is_a?(Proc)
        raise "Cannot infer controller from scope without target_controller or field name"
      end

      scope.to_s.underscore.gsub("/", "_")

    end
    # rescue => e
    #   binding.pry if Rails.env.development?
  end

  def scope_singular
    if scope.is_a?(Proc)
      if instance_variable_defined?(:@target_controller) && @target_controller.present?
        @target_controller.to_s.underscore.gsub("/", "_").singularize
      elsif instance_variable_defined?(:@name) && @name.present?
        @name.to_s.gsub(/_id$/, "").singularize
      else
        raise "Cannot infer singular scope from Proc without target_controller or field name"
      end
    else
      scope.to_s.underscore.singularize
    end
    # rescue => e
    #   binding.pry if Rails.env.development?
  end

  def scope
    @scope ||= begin
      return context.scope if defined?(context)
      return resource.model_name.try(:plural) if defined?(resource)

      raise "Scope is not defined"
    end
  end

  # Host apps that nest routes (resources :users { resources :comments }) have no flat
  # admin_comments_path. When the list is rendered with a parent, fall back to the nested
  # route (admin_user_comments_path) using the parent id parsed from its GlobalID.
  def nested_route_for_parent(segment, params)
    gid = parent_global_id(params)
    return if gid.nil?

    path = namespaced_path("namespace", gid.model_name.underscore, segment)
    [path, gid.model_id] if route_exists_in_main_app?(path)
  end

  def parent_global_id(params)
    encoded = params.with_indifferent_access[:fa_parent]
    encoded ||= context.parent if respond_to?(:context) && context.respond_to?(:parent)
    return if encoded.blank?
    return encoded.to_global_id if encoded.respond_to?(:to_global_id)

    GlobalID.parse(URI.decode_www_form_component(encoded.to_s))
  end

  def paginate(resource, per_page: WillPaginate.per_page)
    resource.paginate(page: params[:page], per_page: per_page)
  end

end
