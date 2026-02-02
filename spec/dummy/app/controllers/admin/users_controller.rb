# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    include FlexiAdmin::Controllers::ResourcesController

    private

    def resource_class
      User
    end

    def permitted_params
      params.require(:user).permit(:full_name, :email, :phone, :personal_number, :role, :user_type)
    end
  end
end
