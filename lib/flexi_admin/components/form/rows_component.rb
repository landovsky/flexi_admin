# frozen_string_literal: true

module FlexiAdmin::Components::Form
  class RowsComponent < ViewComponent::Base
    def call
      content_tag :div, content, class: "divide-y overflow-auto"
    end
  end
end