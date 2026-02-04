# frozen_string_literal: true

module Admin
  class CommentsController < ::ApplicationController
    include FlexiAdmin::Controllers::ResourcesController
    before_action :set_user

    def index
      @comments = @user.comments
      render json: @comments
    end

    def show
      @comment = @user.comments.find(params[:id])
      render plain: "Comment by #{@user.full_name}: #{@comment.body}"
    end

    def new
      @comment = @user.comments.build
      render plain: "New comment for #{@user.full_name} (#{GlobalID.create(@user)})"
    end

    private

    def set_user
      @user = ::User.find(params[:user_id])
    end

    def resource_class
      ::Comment
    end

    def permitted_params
      params.require(:comment).permit(:body)
    end
  end
end
