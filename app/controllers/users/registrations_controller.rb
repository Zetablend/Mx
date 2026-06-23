# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  # skip_before_action :authenticate_request, only: [:create]


  # def create

  #   # First save the user
  #   if resource.save
  #     # Now referral can be created safely
  #     if params[:user][:referral_code].present?
  #       referrer = User.find_by(referral_code: params[:user][:referral_code])

  #       if referrer
  #         UserReferral.create!(
  #           user_id: referrer.id,
  #           referred_user_id: resource.id,  # ✅ correct ID of newly created user
  #           referral_code: params[:user][:referral_code],
  #           status: "Pending",
  #           referral_plan_id: ReferralPlan.first&.id
  #         )
  #       end
  #     end

  #     # if params[:user][:role].present?
  #     #   role = Role.find_by(name: params[:user][:role])
  #     #   resource.role_id = role.id if role
  #     # end

  #     # if params[:user][:role_id].present?
  #     #   role = Role.find_by(id: params[:user][:role_id].to_i)
  #     #   params[:user][:role_id] = role.id if role
  #     # end

  #     token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first rescue nil
  #     render json: {
  #       message: "User registered successfully",
  #       user: resource,
  #       token: token
  #     }, status: :created
  #   else
  #     render json: {
  #       message: "Registration failed",
  #       errors: resource.errors.full_messages
  #     }, status: :unprocessable_entity
  #   end
  # end

  # def create
  #   build_resource(sign_up_params)   # <-- FIXED (creates @user)

  #   if resource.save
  #     # Referral create logic
  #     if params[:user][:referral_code].present?
  #       referrer = User.find_by(referral_code: params[:user][:referral_code])

  #       if referrer
  #         UserReferral.create!(
  #           user_id: referrer.id,
  #           referred_user_id: resource.id,
  #           referral_code: params[:user][:referral_code],
  #           status: "Pending",
  #           referral_plan_id: ReferralPlan.first&.id
  #         )
  #       end
  #     end

  #     # Role ID assignment (user.role_id already accepted from params)
  #     if params[:user][:role_id].present?
  #       resource.role_id = params[:user][:role_id]
  #       resource.save
  #     else
  #       resource.role_id = 2
  #       resource.save

  #     end

  #     token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first rescue nil

  #     render json: {
  #       message: "User registered successfully",
  #       user: resource,
  #       token: token
  #     }, status: :created

  #   else
  #     render json: {
  #       message: "Registration failed",
  #       errors: resource.errors.full_messages
  #     }, status: :unprocessable_entity
  #   end
  # end



  
  # protected

  # def sign_up_params
  #   params.require(:user).permit(
  #     :email, :password, :phone,:name,:role_id, :referral_code
  #   ).tap do |whitelisted|
  #     whitelisted[:name] = whitelisted.delete(:fullName) if whitelisted[:fullName]
  #   end
  # end



  skip_before_action :authenticate_request, only: [:create]

  def create
    build_resource(sign_up_params)

    if resource.save
      # Referral logic
      if params[:user][:referral_code].present?
        referrer = User.find_by(referral_code: params[:user][:referral_code])
        UserReferral.create!(
          user_id: referrer.id,
          referred_user_id: resource.id,
          referral_code: params[:user][:referral_code],
          status: "Pending",
          referral_plan_id: ReferralPlan.first&.id
        ) if referrer
      end

      # Default role
      token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first

      render json: {
        success: true,
        message: "User registered successfully",
        user: {
          id: resource.id,
          email: resource.email,
          name: resource.name,
          role: resource.role
        },
        token: token
      }, status: :created
    else
      render json: {
        success: false,
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  protected

  def sign_up_params
    params.require(:user).permit(
      :email, :password, :phone, :name, :role, :referral_code
    )
  end


end
