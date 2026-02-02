# frozen_string_literal: true

module Admin
  class CommentsController < ::ApplicationController
    include FlexiAdmin::Controllers::ResourcesController

    private

    def resource_class
      Comment
    end

    def permitted_params
      params.require(:comment).permit(:content, :user_id)
    end
  end
end
