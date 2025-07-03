# frozen_string_literal: true

module FlexiAdmin::Components::Resources::BulkAction
  class ModalComponent < FlexiAdmin::Components::Resource::FormComponent
    include FlexiAdmin::Components::Resource::FormMixin
    include FlexiAdmin::Components::Helpers::UrlHelper
    extend FlexiAdmin::Components::Helpers::ActionButtonHelper

    class << self
      attr_accessor :class_name
    end

    attr_reader :context

    renders_one :modal_form

    def initialize(context = nil)
      @context = context

      add_context_options(@context)
      super(nil, disabled: false)
    end

    def before_render
      # Update the action_path now that helpers are available
      if @context&.options
        @context.options[:action_path] = path
      end
    end

    def modal(context, &block)
      render FlexiAdmin::Components::Resources::BulkAction::ModalComponent.new(context) do |component|
        component.with_modal_form(&block)
      end
    end

    def form(url: path, method: :post, **html_options, &block)
      super(url:, css_class: 'modalForm section', method:, **html_options, &block)
    end

    # /observation_images/bulk_action
    def self.path
      class_name = self.class_name&.to_s || to_s
      resource = if class_name.downcase.start_with?(FlexiAdmin::Config.configuration.namespace.downcase)
        class_name.split('::')[1].underscore.gsub('/', '-')
      else
        class_name.underscore.gsub('/', '-')
      end
      "/#{resource.pluralize}/bulk_action"
    end

    # Instance method that handles nested resources
    def path
      if context&.parent.present?
        parent_param_key = "#{context.parent.class.model_name.singular}_id".to_sym
        params = { parent_param_key => context.parent.id }

        parent_scope = context.parent.class.model_name.singular
        nested_scope = "#{parent_scope}_#{context.scope}"
        path_method = namespaced_path('bulk_action', 'namespace', nested_scope)

        begin
          helpers.send(path_method, **params)
        rescue NoMethodError
          begin
            direct_path_method = "bulk_action_admin_#{parent_scope}_#{context.scope}_path"
            helpers.send(direct_path_method, **params)
          rescue NoMethodError
            parent_plural = context.parent.class.model_name.plural
            "/#{parent_plural}/#{context.parent.id}/#{context.scope}/bulk_action"
          end
        end
      else
        self.class.path
      end
    end

    def self.modal_id
      to_s.underscore.gsub('/', '-')
    end

    def add_context_options(context)
      # Means it's been already added by the parent component
      return if context.options[:title].present?

      context.options ||= {}
      context.options[:title] = self.class.title_text
      context.options[:modal_id] = self.class.modal_id
      context.options[:action_path] = self.class.path # Use class method during initialization
      context.options[:class_name] = self.class.to_s
    end
  end
end
