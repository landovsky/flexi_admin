# frozen_string_literal: true

module FlexiAdmin::Components::Resources::BulkAction
  class ModalComponent < FlexiAdmin::Components::Resource::FormComponent
    include FlexiAdmin::Components::Resource::FormMixin
    extend FlexiAdmin::Components::Helpers::ActionButtonHelper

    class << self
      attr_accessor :class_name
    end

    attr_reader :context, :extra_options

    renders_one :modal_form

    def initialize(context = nil, **extra_options)
      @context = context

      add_context_options(context)
      extra_options.each do |key, value|
        context.options[key] = value
      end
      super(nil, disabled: false)
    end

    def modal(context, **options,&block)
      render FlexiAdmin::Components::Resources::BulkAction::ModalComponent.new(context, **options) do |component|
        component.with_modal_form(&block)
      end
    end

    def form(url: self.class.path, method: :post, **html_options, &block)
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

    def self.modal_id
      to_s.underscore.gsub('/', '-')
    end

    def add_context_options(context)
      # Means it's been already added by the parent component
      return if context.options[:title].present?

      context.options ||= {}
      context.options[:title] = self.class.title_text
      context.options[:modal_id] = self.class.modal_id
      context.options[:action_path] = self.class.path
      context.options[:class_name] = self.class.to_s
    end
  end
end