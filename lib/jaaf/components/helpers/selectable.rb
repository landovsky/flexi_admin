# frozen_string_literal: true

module Jaaf::Components::Helpers::Selectable
  def selectable
    @is_selectable = true
  end

  def selectable?
    @is_selectable
  end
end
