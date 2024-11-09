# frozen_string_literal: true

module Flexi::Components::Helpers::IconHelper
  def icon
    self.class.instance_variable_get(:@icon_value) || options[:icon]
  end

  def icon_class
    "bi-#{icon}" if icon.present?
  end
end