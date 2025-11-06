# frozen_string_literal: true

module FlexiAdmin::Components::Resource
  class FormComponent < FlexiAdmin::Components::BaseComponent
    include FlexiAdmin::Components::Resource::FormMixin

    ResourceOrScopeNotDefinedError = Class.new(StandardError)

    attr_reader :resource

    def initialize(resource, disabled: true)
      @resource = resource
      @disabled = disabled
    end

    def disabled
      if defined?(CanCan)
        raise ResourceOrScopeNotDefinedError, "Resource or scope is not defined" if resource.blank? && scope.blank?

        resource_to_check = resource.presence || self.class.class_name || scope.singularize.camelcase.constantize

        !helpers.current_ability&.can?(:update, resource_to_check) || @disabled
      else
        @disabled
      end
    rescue ResourceOrScopeNotDefinedError => e
      BugTracker.notify(e, scope: scope)

      # Let it pass, we need to fix missing scope or resource
      false
    end
  end
end
