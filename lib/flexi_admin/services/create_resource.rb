# frozen_string_literal: true

class FlexiAdmin::Services::CreateResource
  attr_reader :params, :resource_class, :resource, :errors

  def initialize(params:, resource_class:)
    @params = params
    @resource_class = resource_class
    @errors = {}
  end

  def self.run(params:, resource_class:)
    new(params:, resource_class:).run
  end

  def run
    @resource = resource_class.new(params)

    if @resource.save
      @resource
    else
      @errors.merge!(@resource.errors)
      nil
    end

    self
  end

  def valid?
    resource.present? && errors.empty?
  end
end
