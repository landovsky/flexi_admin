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

    def show
      @user = ::User.find(params[:id])

      respond_to do |format|
        format.html { render plain: "User: #{@user.full_name}" }
        format.json { render json: @user }
      end
    end

    def create
      @user = ::User.new(permitted_params)

      if @user.save
        respond_to do |format|
          format.html { redirect_to admin_users_path, notice: 'User created successfully' }
          format.turbo_stream { render turbo_stream: turbo_stream.append('users', partial: 'user', locals: { user: @user }) }
          format.json { render json: @user, status: :created }
        end
      else
        respond_to do |format|
          format.html { render plain: "Error: #{@user.errors.full_messages.join(', ')}", status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      @user = ::User.find(params[:id])

      if @user.update(permitted_params)
        respond_to do |format|
          format.html { redirect_to admin_user_path(@user), notice: 'User updated successfully' }
          format.json { render json: @user }
        end
      else
        respond_to do |format|
          format.html { render plain: "Error: #{@user.errors.full_messages.join(', ')}", status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @user = ::User.find(params[:id])
      @user.destroy

      respond_to do |format|
        format.html { redirect_to admin_users_path, notice: 'User deleted successfully' }
        format.json { head :no_content }
      end
    end

    def bulk_action
      action_type = params[:action]
      ids = params[:ids]

      # Parse JSON if it's a string
      ids = JSON.parse(ids) if ids.is_a?(String)

      if action_type == 'delete' && ids.present?
        ::User.where(id: ids).delete_all
        respond_to do |format|
          format.html { redirect_to admin_users_path, notice: "#{ids.length} users deleted" }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to admin_users_path, alert: 'Unknown action' }
          format.json { render json: { error: 'Unknown action' }, status: :bad_request }
        end
      end
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
