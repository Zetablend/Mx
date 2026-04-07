# app/controllers/api/v1/roles_controller.rb
class Api::V1::RolesController < ApplicationController
    skip_before_action :authenticate_request, only: [:index,  :create ,:update]
    def index
        roles = Role.all
        render json: roles, only: [:id, :name ,:permissions]
    end


  def create
    role = Role.new(role_params)
    if role.save
      render json: role
    else
      render json: { error: role.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    role = Role.find(params[:id])
    if role.update(role_params)
      render json: role
    else
      render json: { error: role.errors.full_messages }, status: :unprocessable_entity
    end
  end




  private

  def role_params
    # params.require(:role).permit(:name)
    params.require(:role).permit(:name, permissions: [])
  end
end
