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
    def new
      @user = parent_instance
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

      # Record the parent in the context so generated links (sorting, pagination,
      # view switch) carry fa_parent and resolve to the nested route.
      context_params.with_parent!(parent_instance) if parent_instance.present?
      render_index(resources)
    end

    private

    # Standard Rails nested URLs (/admin/users/:user_id/comments) carry the parent as
    # :user_id rather than the fa_parent GlobalID the mixin looks for.
    def parent_instance
      @parent_instance ||= super || (::User.find(params[:user_id]) if params[:user_id].present?)
    end

    def resource_class
      ::Comment
    end

    def resource_params
      params.require(:comment).permit(:content)
    end
  end
end
