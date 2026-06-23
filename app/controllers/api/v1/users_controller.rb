class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:profile, :update_profile, :upload_profile_image]

  def profile
    user = User.find(params[:id])

    render json: {
      success: true,
      data: {
        id: user.id,
        name: user.name,
        username: user.respond_to?(:username) ? user.username : nil,
        email: user.email,
        phone: user.phone,
        dob: user.respond_to?(:dob) ? user.dob : nil,
        gender: user.respond_to?(:gender) ? user.gender : nil,
        profile_image: user.respond_to?(:profile_image) ? user.profile_image.url : nil,
        referral_code: user.referral_code,
        loyalty_points: user.respond_to?(:loyalty_points) ? user.loyalty_points : 0,
        member_since: user.created_at.strftime("%Y-%m-%d")
      }
    }
  end

  def upload_profile_image
    user = User.find_by(id: params[:id])

    unless user
      return render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end

    unless params[:image].present?
      return render json: {
        success: false,
        message: "Image is required"
      }, status: :unprocessable_entity
    end

    begin
      user.profile_image.attach(params[:image])

      render json: {
        success: true,
        message: "Profile image uploaded successfully",
        data: {
          profile_image: url_for(user.profile_image)
        }
      }, status: :ok

    rescue => e
      Rails.logger.error "PROFILE IMAGE ERROR: #{e.class} - #{e.message}"

      render json: {
        success: false,
        message: "Failed to upload profile image",
        error: e.message
      }, status: :unprocessable_entity
    end
  end

  def update_profile
    user = User.find(params[:id]) # testing ke liye

    if user.update(profile_params)
      render json: {
        success: true,
        message: "Profile updated successfully"
      }
    else
      render json: {
        success: false,
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.permit(
      :name,
      :username,
      :phone,
      :dob,
      :gender,
      :profile_image
    )
  end
end
