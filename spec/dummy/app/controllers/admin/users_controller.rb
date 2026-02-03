# frozen_string_literal: true

module Admin
  class UsersController < ::ApplicationController
    include FlexiAdmin::Controllers::ResourcesController

    def index
      resources = ::User.all
      # Apply search if present
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        resources = resources.where('full_name LIKE ? OR email LIKE ?', search_term, search_term)
      end
      # Apply role filter if present
      resources = resources.where(role: params[:role]) if params[:role].present?
      # Apply sorting
      if params[:sort_by].present?
        direction = params[:sort_direction] || 'asc'
        resources = resources.order(params[:sort_by] => direction)
      end
      # Paginate
      resources = resources.paginate(page: params[:page] || 1, per_page: params[:per_page] || 16)

      render_index(resources)
    end

    private

    def resource_class
      ::User
    end

    def permitted_params
      params.require(:user).permit(:full_name, :email, :phone, :personal_number, :role, :user_type)
    end
  end
end
