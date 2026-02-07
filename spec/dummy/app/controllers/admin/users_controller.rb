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
        format.html { render Admin::User::ShowPageComponent.new(@user) }
        format.json { render json: @user }
      end
    end

    def create
      Rails.logger.info "=== CREATE ACTION ==="
      Rails.logger.info "Params: #{params.inspect}"
      Rails.logger.info "Permitted params: #{permitted_params.inspect}"

      @user = ::User.new(permitted_params)
      Rails.logger.info "User valid: #{@user.valid?}"
      Rails.logger.info "User errors: #{@user.errors.full_messages}" unless @user.valid?

      if @user.save
        respond_to do |format|
          format.html { redirect_to admin_users_path, notice: 'User created successfully' }
          format.turbo_stream { render turbo_stream: turbo_stream.append('users', partial: 'user', locals: { user: @user }) }
          format.json { render json: @user, status: :created }
        end
      else
        error_message = "Error: #{@user.errors.full_messages.join(', ')}"
        Rails.logger.info "=== CREATE FAILED: #{error_message}"

        respond_to do |format|
          format.html { render plain: error_message, status: :unprocessable_content }
          format.json { render json: @user.errors, status: :unprocessable_content }
        end
      end
    rescue ActionController::ParameterMissing => e
      # Handle missing required parameter
      Rails.logger.info "=== PARAMETER MISSING: #{e.message}"

      respond_to do |format|
        format.html { render plain: "Parameter error: #{e.message}", status: :bad_request }
        format.json { render json: { error: e.message }, status: :bad_request }
      end
    rescue => e
      Rails.logger.error "=== UNEXPECTED ERROR: #{e.class}: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")

      respond_to do |format|
        format.html { render plain: "Unexpected error: #{e.message}", status: :internal_server_error }
        format.json { render json: { error: e.message }, status: :internal_server_error }
      end
    end

    def update
      @user = ::User.find(params[:id])

      if @user.update(permitted_params)
        respond_to do |format|
          format.html { redirect_to admin_user_path(@user), notice: 'User updated successfully' }
          format.json { render json: @user }
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace("user-#{@user.id}",
                partial: 'admin/users/user',
                locals: { user: @user }
              ),
              turbo_stream.prepend('toasts',
                partial: 'shared/toast',
                locals: { message: 'User updated successfully', type: 'success' }
              )
            ]
          end
        end
      else
        respond_to do |format|
          format.html { render plain: "Error: #{@user.errors.full_messages.join(', ')}", status: :unprocessable_content }
          format.json { render json: @user.errors, status: :unprocessable_content }
          format.turbo_stream do
            render turbo_stream: turbo_stream.prepend('toasts',
              partial: 'shared/toast',
              locals: {
                message: "Failed to update user: #{@user.errors.full_messages.join(', ')}",
                type: 'error'
              }
            ), status: :unprocessable_entity
          end
        end
      end
    end

    def destroy
      @user = ::User.find(params[:id])
      @user.destroy

      respond_to do |format|
        format.html { redirect_to admin_users_path, notice: 'User deleted successfully' }
        format.json { head :no_content }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("user-#{@user.id}"),
            turbo_stream.prepend('toasts',
              partial: 'shared/toast',
              locals: { message: 'User deleted successfully', type: 'success' }
            )
          ]
        end
      end
    end

    def bulk_action
      action_type = params[:bulk_action_type]
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
