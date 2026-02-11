# frozen_string_literal: true

module Admin
  class UsersController < ::ApplicationController
    include FlexiAdmin::Controllers::ResourcesController

    def index
      resources = ::User.all
      # Apply search if present
      if params[:q].present?
        search_term = "%#{params[:q]}%"
        resources = resources.where('full_name LIKE ? OR email LIKE ?', search_term, search_term)
      end
      # Apply role filter if present
      resources = resources.where(role: params[:role]) if params[:role].present?
      # Apply sorting
      resources = if fa_sorted?
                    resources.order(fa_sort => fa_order)
                  else
                    resources.order(full_name: :asc)
                  end
      # Paginate
      resources = resources.paginate(**context_params.pagination)

      render_index(resources)
    end

    private

    def resource_class
      ::User
    end

    def resource_params
      params.require(:user).permit(:full_name, :email, :phone, :personal_number, :role, :user_type)
    end
  end
end
