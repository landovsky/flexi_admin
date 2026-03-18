# frozen_string_literal: true

# Dependent component, context required.
module FlexiAdmin::Components::Resources
  class GridViewComponent < FlexiAdmin::Components::BaseComponent
    include FlexiAdmin::Components::Helpers::ValueFormatter
    include FlexiAdmin::Components::Helpers::ResourceHelper
    include FlexiAdmin::Components::Helpers::Selectable
    include FlexiAdmin::Components::Helpers::LinkHelper

    class Element < Struct.new(:attribute, :value, :options, :main_app)
      include FlexiAdmin::Components::Helpers::UrlHelper

      def formatted_value(value)
        options[:formatter].call(value)
      end

      def src(image, variant: nil)
        raise "ActiveStorage::Attached::One required, got #{image.class}" if image.class != ActiveStorage::Attached::One

        return unless variant && image.attached?

        main_app.url_for(image.variant(variant))
      rescue ActiveStorage::InvariableError
        main_app.url_for(image)
      end

      def media_type(resource)
        resource.media_type.to_s
      end
    end

    attr_reader :context, :resources, :resource
    attr_accessor :title_element, :header_element, :description_element, :image_element, :quick_action_block

    def initialize(context)
      @context = context
      @resources = context.resources

      @is_selectable = false
    end

    def grid_view
      yield

      grid
    rescue StandardError => e
      binding.pry if Rails.env.development?
    end

    def grid
      render FlexiAdmin::Components::Resources::GridView::GridComponent.new(resources, title_element, header_element,
                                                                            description_element,
                                                                            image_element, quick_action_block,
                                                                            context)
    end

    def render?
      context.params.current_view == "grid" ||
        (context.views.first == "grid" && context.params.current_view.blank?)
    end

    def image(src_attribute, **options, &block)
      value = block || proc { |resource| resource.send(src_attribute) }

      self.image_element = Element.new(src_attribute, value, options, main_app)
    end

    def title(attribute, **options, &block)
      value = block || proc { |resource| resource.send(attribute) }
      options[:formatter] = format(options[:as] || :text)

      self.title_element = Element.new(attribute, value, options)
    end

    def header(attribute, **options, &block)
      value = block || proc { |resource| resource.send(attribute) }
      options[:formatter] = format(options[:as] || :text)

      self.header_element = Element.new(attribute, value, options)
    end

    def description(attribute, **options, &block)
      value = block || proc { |resource| resource.send(attribute) }
      options[:formatter] = format(options[:as] || :text)

      self.description_element = Element.new(attribute, value, options)
    end

    def quick_action(&block)
      self.quick_action_block = block
    end
  end
end
