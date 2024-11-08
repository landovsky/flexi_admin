# frozen_string_literal: true

class Actions::CheckboxComponent < ViewComponent::Base
  attr_reader :id, :scope, :select_all

  def initialize(id:, scope:, select_all: false)
    @id = id
    @scope = scope
    @select_all = select_all
  end
end
