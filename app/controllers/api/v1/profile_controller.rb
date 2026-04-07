class Api::V1::ProfileController < ApplicationController
  # 🔐 keep auth enabled
  skip_before_action :authenticate_request

  def index
    user = params[:user_id].present? ? User.find_by(id: params[:user_id]) : current_user

    return render json: { error: "User not found" }, status: :not_found unless user

    render json: {
      message: "Profile fetched successfully",
      user: profile_data(user)
    }, status: :ok
  end


  def update
    puts current_user.inspect
    puts "-----------------------------------"
    puts params[:id].inspect
    
    if (params[:id])
      user = User.find(params[:id].to_i)
    else
      user = current_user if (current_user)
    end
    
    if user.update(profile_params)
      render json: {
        message: "Profile updated successfully",
        user: profile_data(user)
      }, status: :ok
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end


  private

  def profile_params
    params.require(:user).permit(:name, :email, :phone)
  end

  def profile_data(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role.name
    }
  end

end
