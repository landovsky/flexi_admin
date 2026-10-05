# frozen_string_literal: true

# ============================================================================
# FLEXI ADMIN EXAMPLE: Nested Resource Controller
# ============================================================================
# Comments are nested under Users. The controller uses parent_instance
# (from context_params) to scope queries to the parent user.
#
# For nested resources, the parent is encoded as a GlobalID in the fa_parent
# query param and decoded automatically by the mixin's parent_instance method.
# ============================================================================

module Admin
  class CommentsController < ::ApplicationController
    include FlexiAdmin::Controllers::ResourcesController

    # The mixin does NOT provide a `new` action — define it manually.
    # For nested routes, use params[:user_id] since the parent isn't
    # encoded as fa_parent in standard Rails nested URLs.
    def new
      @user = parent_instance || ::User.find(params[:user_id])
      @comment = @user.comments.build
      render Admin::Comment::NewFormComponent.new(@comment, parent: @user)
    end

    def index
      resources = if parent_instance.present?
                    parent_instance.comments
                  else
                    ::Comment.all
                  end

      resources = resources.order(created_at: :desc)
      resources = resources.paginate(**context_params.pagination)

      render_index(resources)
    end

    private

    def resource_class
      ::Comment
    end

    def resource_params
      params.require(:comment).permit(:content)
    end
  end
end
