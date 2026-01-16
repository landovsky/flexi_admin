# frozen_string_literal: true

module FlexiAdmin::Components::Resource
  class LinkActionComponent < FlexiAdmin::Components::BaseComponent
    extend FlexiAdmin::Components::Helpers::ActionButtonHelper
    include FlexiAdmin::Components::Helpers::IconHelper

    attr_reader :label, :path, :options, :disabled

    def initialize(label, path, disabled: false, **options)
      @label = label
      @path = path
      @options = options
      @disabled = disabled
    end
  end
end
