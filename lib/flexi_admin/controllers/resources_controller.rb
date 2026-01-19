# frozen_string_literal: true

module FlexiAdmin::Controllers::ResourcesController
  extend ActiveSupport::Concern

  DEFAULT_CONTROLLER_PARAMS_KEYS = %i[controller action subdomain commit button].freeze
  # rescue_from RuntimeError, with: :handle_runtime_error

  included do
    before_action :context_params

    if defined?(CanCan::AccessDenied)
      rescue_from CanCan::AccessDenied do |exception|
        flash[:error] = FlexiAdmin::Models::Toast.new(exception.message)
        respond_to do |format|
          format.html do
            render 'shared/not_authorized'
          end

          format.turbo_stream do
            render_toasts
          end
        end
      end
    end
  end

  def render_toasts
    render turbo_stream: turbo_stream.append('toasts', partial: 'shared/toasts')
  end

  def append_toasts
    turbo_stream.append('toasts', partial: 'shared/toasts')
  end

  def render_index(resources, target: nil)
    target = target || (fa_sorting_active? ? resource_class.model_name.plural : context_params.frame)

    respond_to do |format|
      format.html do
        component_class = namespaced_class('namespace', resource_class.name, "IndexPageComponent")
        puts "component_class: #{component_class}"
        render component_class.new(resources, context_params: context_params,
                                              scope: resource_class.model_name.plural)
      end
      format.turbo_stream do
        component_class = namespaced_class('namespace', resource_class.name, "ResourcesComponent")
        render turbo_stream: turbo_stream.replace(target, component_class.new(resources, context_params: context_params,
                                                                                         scope: resource_class.model_name.plural,
                                                                                         parent: parent_instance))
      end
    end
  end

  # Deprecated
  def reload_page
    render turbo_stream: [
      turbo_stream.append('system', partial: 'shared/reload'),
      turbo_stream.append('toasts', partial: 'shared/toasts')
    ]
  end

  def redirect_to_path(path)
    render turbo_stream: turbo_stream.append('system', partial: 'shared/redirect', locals: { path: path })
  end

  def context_params
    @context_params ||= FlexiAdmin::Models::ContextParams.new(context_permitted_params)
  end

  def context_permitted_params
    @context_permitted_params ||= begin
      permitted_keys = FlexiAdmin::Models::ContextParams.permitted_params_keys.dup

      array_param_keys = params.select { |_k, v| v.is_a?(Array) }.keys
      array_params = array_param_keys.map { |k| { k => [] } }
      scalar_params = params.except(:controller, *DEFAULT_CONTROLLER_PARAMS_KEYS).keys - array_param_keys

      params.permit(
        *permitted_keys,
        *scalar_params,
        *array_params
      )
    end
  end

  def handle_runtime_error(error)
    return BugTracker.notify(error) if true

    flash[:error] = FlexiAdmin::Models::Toast.new(error.message)

    render_toasts
  end

  def create
    authorize! :create, resource_class if defined?(CanCan)

    result = nil
    if respond_to?(:create_service)
      Rails.logger.debug "ResourcesController: #{__method__} using custom controller create_service."
      result = create_service(resource: parent_instance, params: resource_params)
    else
      create_service = begin
        class_name = namespaced_class('namespace', resource_class.model_name.plural.camelize, "Services", "Create")
        Rails.logger.debug "ResourcesController: #{__method__} using class_name: #{class_name}"
        class_name
      rescue NameError
        Rails.logger.debug "ResourcesController: #{__method__} using generic FlexiAdmin::Services::CreateResource"
        FlexiAdmin::Services::CreateResource
      end

      result = create_service.run(resource_class:, params: resource_params)
    end

    if result.valid?
      redirect_to_path resource_path(result.resource)
    else
      render_new_resource_form(result.resource)
    end
  end

  def show
    @resource = resource_class.find(params[:id])
    authorize! :show, @resource if defined?(CanCan)

    respond_to do |format|
      format.html do
        component ||= namespaced_class('namespace', resource_class.name, "Show", "PageComponent")
        render component.new(@resource, context_params:, scope: resource_class.model_name.plural)
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(context_params.frame)
      end
    end
  end

  def edit
    @resource = resource_class.find(params[:id])
    authorize! :update, @resource if defined?(CanCan)

    render_edit_resource_form(disabled: disabled?(context_params.form_disabled))
  end

  def update
    @resource = resource_class.find(params[:id])
    authorize! :update, @resource if defined?(CanCan)

    result = nil
    if result = try(:update_service, resource: @resource, params: resource_params)
      Rails.logger.debug "ResourcesController: #{__method__} using custom controller update_service."
      result = update_service(resource: @resource, params: resource_params)
    else
      update_service = begin
        class_name = namespaced_class('namespace', 'namespace',"#{resource_class.model_name.plural.camelize}", "Services", "Update")
        Rails.logger.debug "ResourcesController: #{__method__} using class_name: #{class_name}"

        class_name
      rescue NameError
        Rails.logger.debug "ResourcesController: #{__method__} using generic FlexiAdmin::Services::UpdateResource"
        FlexiAdmin::Services::UpdateResource
      end

      result = update_service.run(resource: @resource, params: resource_params)
    end

    if result.valid?
      render_edit_resource_form(disabled: disabled?(true))
    else
      Rails.logger.debug "ResourcesController: #{__method__} errors: #{result.errors.full_messages}"
      render_edit_resource_form(disabled: disabled?(false))
    end
  end

  def destroy
    @resource = resource_class.find(params[:id])
    authorize! :destroy, @resource if defined?(CanCan)

    if @resource.destroy
      success_message = I18n.t('flexi_admin.messages.destroy.success',
                               resource: resource_class.model_name.human)
      flash[:success] = FlexiAdmin::Models::Toast.new(success_message)

      namespace = FlexiAdmin::Config.configuration.namespace
      path_segments = namespace.present? ? [namespace.to_sym, resource_class] : [resource_class]
      index_path = polymorphic_path(path_segments)

      redirect_to_path index_path
    else
      error_message = I18n.t('flexi_admin.messages.destroy.failure',
                            resource: resource_class.model_name.human)
      flash[:error] = FlexiAdmin::Models::Toast.new(error_message)
      render_toasts
    end
  end

  def render_edit_resource_form(disabled: true)
    respond_to do |format|
      format.html do
        render turbo_stream: turbo_stream.replace(@resource.form_id, edit_form_component_instance(disabled?(disabled)))
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(@resource.form_id, edit_form_component_instance(disabled?(disabled)))
      end
    end
  end

  def render_new_resource_form(resource)
    respond_to do |format|
      format.html do
        render new_form_component_instance(resource)
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(context_params.frame, new_form_component_instance(resource))
      end
    end
  end

  def bulk_action
    ids = JSON.parse(params[:ids])

    # Unscoped is needed to get the resources that are not deleted, archived, etc.
    # It should be ok, since we control the ids in the frontend
    @resources = resource_class.unscoped.where(id: ids)

    authorize! :edit, @resources.presence&.base_class || resource_class if defined?(CanCan)

    # TODO: improve this
    params.merge!(current_user: current_user)
    bulk_processor = if params[:processor].gsub('-', '/').camelize.include?(FlexiAdmin::Config.configuration.module_namespace)
                      namespaced_class(params[:processor].gsub('-', '/').camelize, "Processor").new(@resources, params)
    else
      namespaced_class(FlexiAdmin::Config.configuration.module_namespace, params[:processor].gsub('-', '/').camelize, "Processor").new(@resources, params)
    end

    result = bulk_processor.perform

    redirect_to_path result.path and return if result.result == :redirect

    flash[result.result] = FlexiAdmin::Models::Toast.new(result.message)

    result.redirect_to.present? ? redirect_to_path(result.redirect_to) : reload_page
  end

  def autocomplete(includes: nil)
    base_query = if context_params.params[:custom_scope].present?
                   # Handle custom scope passed from component
                   deserialize_and_apply_custom_scope(resource_class, context_params.params[:custom_scope])
                 else
                   resource_class.with_parent(parent_instance)
                 end

    base_query = base_query.fulltext(params[:q])
    base_query = base_query.includes(includes) if includes.present?
    results_count = base_query.count
    results = base_query.limit(100)

    render FlexiAdmin::Components::Shared::Autocomplete::ResultsComponent.new(results:,
                                                                         results_count:,
                                                                         context_params:), layout: false
  end

  def datalist
    results = resource_class.fulltext(params[:q])
                            .limit(100)
                            .order(*context_params.params[:ac_fields].map(&:to_sym))
                            .pluck(*context_params.params[:ac_fields].map(&:to_sym))
                            .uniq

    render FlexiAdmin::Components::Shared::Autocomplete::ResultsComponent.new(results:,
                                                                              context_params:), layout: false
  end

  private

  def parent_instance
    @parent_instance ||= locate_resource(context_params.parent)
  end

  def edit_form_component_instance(disabled)
    namespaced_class('namespace', "#{@resource.class.name}", "Show", "EditFormComponent").new(@resource, disabled: disabled?(disabled))
  end

  def new_form_component_instance(resource)
    namespaced_class('namespace', "#{resource.class.name}", "NewFormComponent").new(resource, parent: parent_instance)
  end

  def locate_resource(encoded_gid)
    return nil if encoded_gid.blank?

    gid = URI.decode_www_form_component(encoded_gid)
    resource = GlobalID::Locator.locate(gid)

    raise ActiveRecord::RecordNotFound, "Resource not found: #{encoded_gid}" if resource.blank?

    resource
  end

  def resource_class
    controller_path = self.class.name.deconstantize
    config_namespace = FlexiAdmin::Config.configuration.namespace&.camelize

    if config_namespace.present? && controller_path.start_with?(config_namespace)
      if controller_path == config_namespace
        controller_name.classify.constantize
      else
        module_path = controller_path.sub(/^#{Regexp.escape(config_namespace)}::/, '')
        class_name = "#{module_path}::#{controller_name.classify}"
        Object.const_get(class_name)
      end
    else
      controller_name.classify.constantize
    end
  end

  def fa_sorted?
    fa_sort.present? && fa_order.present? && fa_order != "default"
  end

  def fa_sorting_active?
    fa_sort.present? && fa_order.present?
  end

  def fa_sort
    context_params[:sort]
  end

  def fa_order
    context_params[:order]
  end

  def disabled?(form_disabled = false)
    if defined?(CanCan)
      !current_ability&.can?(:update, resource_class) || form_disabled
    else
      form_disabled
    end
  end

  def namespaced_class(*segments)
    config_namespace = FlexiAdmin::Config.configuration.namespace&.camelize

    modules = segments.compact.flat_map do |segment|
      if segment == 'namespace'
        config_namespace
      elsif segment.include?('::')
        segment.split('::')
      else
        segment
      end
    end.compact

    modules.join("::").constantize
  rescue NameError => e
    Rails.logger.warn "Failed to find class: #{modules.join("::")}"
    raise NameError, "Failed to find class: #{modules.join("::")}"
  end

  def deserialize_and_apply_custom_scope(resource_class, scope_key)
    custom_scope = FlexiAdmin::Components::Helpers::CustomScopeRegistry.get(scope_key)

    return resource_class.all unless custom_scope

    case custom_scope
    when Proc
      custom_scope.call(resource_class)
    else
      resource_class.all
    end
  rescue => e
    Rails.logger.warn "Failed to apply custom scope: #{e.message}"
    resource_class.all
  end
end
