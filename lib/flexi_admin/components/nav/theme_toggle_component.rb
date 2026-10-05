# frozen_string_literal: true

# Button cycling the color theme auto → light → dark. Requires ThemeScriptComponent in <head>.
#
#   = render FlexiAdmin::Components::Nav::ThemeToggleComponent.new
module FlexiAdmin::Components::Nav
  class ThemeToggleComponent < FlexiAdmin::Components::BaseComponent
    def initialize(css_class: "btn btn-outline-secondary btn-sm")
      @css_class = css_class
    end

    def call
      content_tag(:button, type: "button", class: "flexi-theme-toggle #{@css_class}",
                           data: { controller: "theme", action: "theme#cycle" },
                           "aria-label": "Color theme") do
        safe_join([
          content_tag(:i, "", class: "bi bi-circle-half", data: { "theme-target": "icon" }),
          content_tag(:span, "Auto", class: "ms-1 d-none d-sm-inline", data: { "theme-target": "label" })
        ])
      end
    end
  end
end
