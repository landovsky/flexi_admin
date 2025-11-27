# frozen_string_literal: true

module FlexiAdmin::Components::Resources::BulkAction
  # Component for rendering action buttons on individual rows (not bulk selection)
  # Opens a modal for a single item action
  class RowActionButtonComponent < FlexiAdmin::Components::BaseComponent
    include FlexiAdmin::Components::Helpers::UrlHelper
    include FlexiAdmin::Components::Helpers::IconHelper

    attr_reader :item, :context, :modal_class, :options, :dropdown_mode, :hide_icon, :disabled

    def initialize(item, context, modal_class, dropdown: false, hide_icon: false, disabled: false, **options)
      super(nil)
      @item = item
      @context = context
      @modal_class = modal_class
      @dropdown_mode = dropdown
      @hide_icon = hide_icon
      @disabled = disabled
      @options = options
    end

    def dropdown_mode?
      @dropdown_mode
    end

    def disabled?
      @disabled
    end

    def button_text
      modal_class.button_text
    end

    def button_icon
      modal_class.button_icon
    end

    def button_icon_class
      modal_class.button_icon_class if button_icon.present?
    end

    def show_icon?
      !@hide_icon && button_icon.present?
    end

    def scoped_url_with_modal_id
      path = namespaced_path("flexi_admin", "modals")

      item_params = context.params.merge(
        selected_ids: [item.id],
        scope: context.scope
      )

      url_params = {
        kind: modal_class.modal_id,
        **item_params.to_params
      }

      if route_exists_in_main_app?(path)
        main_app.send(path, url_params)
      else
        helpers.send(path, url_params)
      end
    end

    def css_classes
      if dropdown_mode?
        classes = %w[dropdown-item]
      else
        classes = %w[btn btn-sm btn-outline-primary]
      end
      classes << "text-muted" if disabled?
      classes.concat(options[:class].split) if options[:class]
      classes.join(" ")
    end
  end
end
