# frozen_string_literal: true

# ============================================================================
# FLEXI ADMIN EXAMPLE: Controller
# ============================================================================
# Admin controllers include FlexiAdmin::Controllers::ResourcesController which
# provides: show, create, update, destroy, edit, bulk_action, autocomplete.
#
# You typically only override `index` for custom filtering/sorting/search.
# The mixin auto-discovers components by naming convention:
#   Admin::User::IndexPageComponent, Admin::User::ResourcesComponent,
#   Admin::User::Show::PageComponent, Admin::User::Show::EditFormComponent, etc.
# ============================================================================

module Admin
  class UsersController < ::ApplicationController
    include FlexiAdmin::Controllers::ResourcesController

    def index
      resources = ::User.all

      # --- Full-text search ---
      # Wire up to the search_field in FilterComponent.
      # The model should define a `fulltext` scope for autocomplete to work too.
      resources = resources.fulltext(params[:q]) if params[:q].present?

      # --- Filters ---
      # Each filter key matches a param name from FilterComponent's filter_options.
      resources = resources.where(role: params[:role]) if params[:role].present?
      resources = resources.where(user_type: params[:user_type]) if params[:user_type].present?

      # --- Sorting ---
      # fa_sorted? returns true when user clicked a sortable column header.
      # fa_sort returns the column name, fa_order returns :asc/:desc.
      resources = if fa_sorted?
                    resources.order(fa_sort => fa_order)
                  else
                    resources.order(full_name: :asc)
                  end

      # --- Pagination ---
      # context_params.pagination returns { page:, per_page: } from fa_page/fa_per_page params.
      resources = resources.paginate(**context_params.pagination)

      # render_index renders the IndexPageComponent, with turbo_stream support
      # for sorting/filtering without full page reload.
      render_index(resources)
    end

    private

    # Required: tells the mixin which model to use for show/create/update/destroy.
    def resource_class
      ::User
    end

    # Required: strong parameters for create/update.
    def resource_params
      params.require(:user).permit(:full_name, :email, :phone, :personal_number, :role, :user_type)
    end
  end
end
