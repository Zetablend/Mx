# class Api::V1::UserDetailsController < ApplicationController
#   skip_before_action :authenticate_request, only: [:show, :update, :destroy, :index ,:create]
#   before_action :set_user_detail, only: [:show, :update, :destroy]


#   # GET /user_details
#   def index
#     @user_details = User.all
#     render json: @user_details
#   end

#   # GET /user_details/:id
#   def show
#     render json: @user_detail
#   end

#   # POST /user_details
#   # def create
#   #   @user_detail = User.new(user_detail_params)

#   #   if @user_detail.save
#   #     render json: { message: "User created successfully", user: @user_detail }, status: :created
#   #   else
#   #     render json: { errors: @user_detail.errors.full_messages }, status: :unprocessable_entity
#   #   end
#   # end

#   def create
#     user_params = params.require(:user).permit(:name, :email, :phone, :role, :password, :password_confirmation)
#     user = User.find_by(email: user_params[:email])
#     if user
#       render json: { message: "User already exists", user: user }, status: :ok
#     else
#       new_user = User.new(user_params)
#       if new_user.save
#         render json: { message: "User created successfully", user: new_user }, status: :created
#       else
#         render json: { errors: new_user.errors.full_messages }, status: :unprocessable_entity
#       end
#     end
#   end





#   # PUT /user_details/:id
#   def update
#     if @user_detail.update(user_detail_params)
#       render json: { message: "User updated successfully", user: @user_detail }
#     else
#       render json: { errors: @user_detail.errors.full_messages }, status: :unprocessable_entity
#     end
#   end

#   # DELETE /user_details/:id
#   def destroy
#     @user_detail.destroy
#     render json: { message: "User deleted successfully" }
#   end

#   private

#   def set_user_detail
#     @user_detail = User.find(params[:id])
#   end

#   def user_detail_params
#     params.require(:user).permit(:name, :email, :phone, :role)
#   end
# end
class Api::V1::UserDetailsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :create, :update, :destroy, :show , :block, :verify, :update_status, :import]
  before_action :set_user_detail, only: [:show, :update, :destroy, :update_status, :block, :verify]

  # GET /user_details
  def index
    # Exclude Admin users
    users = User.joins(:role)
                .where.not(roles: { name: "Admin" })
                .select("users.id, users.name, users.email, users.status,roles.name AS role_name")

    render json: users.map { |u|
      {
        id: u.id,
        name: u.name,
        email: u.email,
        role: u.role_name,
        status: u.status
      }
    }
  end


  # GET /user_details/:id
  def show
    render json: @user_detail
  end

  # POST /user_details
  def create
    user_params = params.require(:user).permit(:name, :email, :phone, :role, :password)
    user = User.new(user_params.merge(status: "active", verified: false, blocked: false))

    if user.save
      render json: { message: "User created", user: user }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /user_details/:id
  def update
    if @user_detail.update(user_detail_params)
      render json: { message: "Updated", user: @user_detail }
    else
      render json: { errors: @user_detail.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /user_details/:id
  def destroy
    @user_detail.destroy
    render json: { message: "Deleted" }
  end

  # PATCH /user_details/:id/update_status
  def update_status
    @user_detail.update(status: params[:status])
    render json: { message: "Status updated", user: @user_detail }
  end

  # PATCH /user_details/:id/block
  def block
    @user_detail.update(blocked: params[:blocked])
    render json: { message: "Block status updated", user: @user_detail }
  end

  # PATCH /user_details/:id/verify
  def verify
    @user_detail.update(verified: true)
    render json: { message: "User verified", user: @user_detail }
  end

  def import
    user_role_id = Role.find_by(name: 'User')&.id

    params[:users].each do |u|
      User.create(
        name: u["name"],
        email: u["email"],
        phone: u["phone"],
        role_id: user_role_id
      )
    end

    render json: { message: "Imported successfully" }
  end




  private

  def set_user_detail
    @user_detail = User.find(params[:id])
  end

  def user_detail_params
    params.require(:user).permit(:name, :email, :phone, :role)
  end
end
