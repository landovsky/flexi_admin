# frozen_string_literal: true

module FlexiAdmin::Controllers::ResourcesController
  extend ActiveSupport::Concern
  # rescue_from RuntimeError, with: :handle_runtime_error

  included do
    before_action :context_params

    rescue_from CanCan::AccessDenied do |exception|
      flash[:error] = FlexiAdmin::Models::Toast.new(exception.message)
      render_toasts
    end
  end

  def render_toasts
    render turbo_stream: turbo_stream.append('toasts', partial: 'shared/toasts')
  end

  def append_toasts
    turbo_stream.append('toasts', partial: 'shared/toasts')
  end

  def render_index(resources, target: nil)
    target ||= context_params.frame
    respond_to do |format|
      format.html do
        component_class = "Admin::#{resource_class.name}::IndexPageComponent".constantize
        render component_class.new(resources, context_params:, scope: resource_class.to_s.downcase)
      end
      format.turbo_stream do
        component_class = "Admin::#{resource_class.name}::ResourcesComponent".constantize
        render turbo_stream: turbo_stream.replace(target, component_class.new(resources, context_params:, scope: resource_class.to_s.downcase))
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
    render turbo_stream: turbo_stream.append('system', partial: 'shared/redirect', locals: { path: })
  end

  def context_params
    @context_params ||= FlexiAdmin::Models::ContextParams.new(context_permitted_params)
  end

  def context_permitted_params
    @context_permitted_params ||= params.permit(*FlexiAdmin::Models::ContextParams.permitted_params_keys)
  end


  def handle_runtime_error(error)
    return BugTracker.notify(error) if true

    flash[:error] = FlexiAdmin::Models::Toast.new(error.message)

    render_toasts
  end

  def create
    authorize! :create, resource_class

    create_service = begin
      "#{resource_class.model_name.plural.camelize}::Services::Create".constantize
    rescue NameError
      FlexiAdmin::Services::CreateResource
    end

    result = create_service.run(resource_class:, params: create_params)

    if result.valid?
      redirect_to_path polymorphic_path([:admin, result.resource])
    else
      render_new_resource_form(result.resource)
    end
  end

  def show
    @resource = resource_class.find(params[:id])
    authorize! :show, @resource

    respond_to do |format|
      format.html do
        component ||= "Admin::#{resource_class.name}::Show::PageComponent".constantize
        render component.new(@resource, context_params:, scope: resource_class.to_s.downcase)
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(context_params.frame)
      end
    end
  end

  def edit
    @resource = resource_class.find(params[:id])
    authorize! :update, @resource

    render_edit_resource_form(disabled: disabled?(context_params.form_disabled))
  end

  def update
    @resource = resource_class.find(params[:id])
    authorize! :update, @resource

    update_service = begin
      "#{resource_class.model_name.plural.camelize}::Services::Update".constantize
    rescue NameError
      FlexiAdmin::Services::UpdateResource
    end

    result = update_service.run(resource: @resource, params: resource_params)

    if result.valid?
      render_edit_resource_form(disabled: disabled?(true))
    else
      render_edit_resource_form(disabled: disabled?(false))
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
    authorize! :edit, @resources

    bulk_processor = "#{params[:processor].gsub('-', '/').camelize}::Processor".constantize.new(@resources, params)
    result = bulk_processor.perform

    redirect_to_path result.path and return if result.result == :redirect

    flash[result.result] = FlexiAdmin::Models::Toast.new(result.message)

    reload_page
  end

  def autocomplete(includes: nil)
    base_query = resource_class.with_parent(parent_instance)
                                .fulltext(params[:q])
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
    [FlexiAdmin::NAMESPACE, "#{@resource.class.name}::Show::EditFormComponent"].join("::").constantize.new(@resource, disabled: disabled?(disabled))
  end

  def new_form_component_instance(resource)
    "#{resource.class.name}::NewFormComponent".constantize.new(resource, parent: parent_instance)
  end

  def locate_resource(encoded_gid)
    return nil if encoded_gid.blank?

    gid = URI.decode_www_form_component(encoded_gid)
    resource = GlobalID::Locator.locate(gid)

    raise ActiveRecord::RecordNotFound, "Resource not found: #{encoded_gid}" if resource.blank?

    resource
  end

  def resource_class
    controller_name.classify.constantize
  end

  def fa_sorted?
    fa_sort.present? && fa_order.present? && fa_order != "default"
  end

  def fa_sort
    context_params[:sort]
  end

  def fa_order
    context_params[:order]
  end

  def disabled?(form_disabled = false)
    !current_ability&.can?(:update, resource_class) || form_disabled
  end
end
