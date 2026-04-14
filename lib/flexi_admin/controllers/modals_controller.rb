# frozen_string_literal: true

class FlexiAdmin::Controllers::ModalsController < ActionController::Base
  include FlexiAdmin::Controllers::ResourcesController

  def show
    component_class = params[:kind].gsub("-", "/").camelize.constantize

    raise ArgumentError, "scope is required" if context_params.scope.blank?

    context = FlexiAdmin::Models::Resources::Context.from_params(context_params)

    render turbo_stream: turbo_stream.update("modalx_#{context.scope_id}", component_class.new(context))
  end
end
