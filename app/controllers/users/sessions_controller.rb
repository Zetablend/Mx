# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
  # skip_before_action :authenticate_request

  # POST /users/send_otp
  # def send_otp
  #   user = User.find_by(email: params[:email])
  #   if user
  #     user.generate_otp!
  #     puts "------------------------------------------user--------------------"
  #     puts user.inspect
  #     # UserMailer.send_otp(user).deliver_later
  #     render json: { success: true, message: "OTP sent to email" }
  #   else
  #     render json: { success: false, message: "User not found" }, status: 404
  #   end
  # end

  # def verify_otp
  #   user = User.find_by(email: params[:email])
  #   if user&.otp == params[:otp] && user.otp_sent_at > 5.minutes.ago
  #     # generate temporary token for password login
  #     token = SecureRandom.hex(10)
  #     user.update(otp_token: token, otp_token_sent_at: Time.current)
  #     user.update(otp: nil, otp_sent_at: nil) # clear OTP
  #     render json: { success: true, message: "OTP verified", otp_token: token }
  #   else
  #     render json: { success: false, message: "Invalid or expired OTP" }, status: 401
  #   end
  # end

  # # POST /users/password_login
  # def password_login
  #   user = User.find_by(otp_token: params[:otp_token])
  #   if user&.valid_password?(params[:password])
  #     sign_in(user)
  #     user.update(otp_token: nil, otp_token_sent_at: nil)
  #     render json: { success: true, message: "Logged in", user: { email: user.email, name: user.name } }
  #   else
  #     render json: { success: false, message: "Invalid password or OTP token" }, status: 401
  #   end
  # end

    # POST /users/send_otp
  # def send_otp
  #   user = User.find_by(email: params[:email])
  #   if user
  #     otp_code = rand(100000..999999).to_s
  #     user.update(otp: otp_code, otp_sent_at: Time.current)
      
  #     # Send OTP email (implement your mailer)
  #     # UserMailer.with(user: user, otp: otp_code).send_otp_email.deliver_later

  #     render json: { success: true, message: "OTP sent successfully" }
  #   else
  #     render json: { success: false, message: "User not found" }, status: 404
  #   end
  # rescue => e
  #   render json: { success: false, message: e.message }, status: 500
  # end

  # POST /users/verify_otp
  # def verify_otp
  #   user = User.find_by(email: params[:email])
  #   if user&.otp == params[:otp] && user.otp_sent_at > 5.minutes.ago
  #     # Clear OTP
  #     user.update(otp: nil, otp_sent_at: nil)

  #     # Generate a temporary OTP token for password login (optional)
  #     otp_token = SecureRandom.hex(10)
  #     user.update(otp_token: otp_token, otp_token_sent_at: Time.current)

  #     render json: { success: true, message: "OTP verified", otp_token: otp_token }
  #   else
  #     render json: { success: false, message: "Invalid or expired OTP" }, status: 401
  #   end
  # end

  # POST /users/password_login
  # def password_login
  #   user = User.find_by(otp_token: params[:otp_token])
  #   if user&.valid_password?(params[:password])
  #     # Generate JWT token like registration
  #     token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first rescue nil

  #     # Clear temporary otp_token
  #     user.update(otp_token: nil, otp_token_sent_at: nil)

  #     render json: {
  #       success: true,
  #       message: "Logged in successfully",
  #       user: { email: user.email, name: user.name ,role: user.role.name , id: user.id},
  #       token: token
  #     }
  #   else
  #     render json: { success: false, message: "Invalid password or OTP token" }, status: 401
  #   end
  # end

  skip_before_action :authenticate_request, only: [
    :new,
    :create,
    :send_otp,
    :verify_otp,
    :password_login,
    :forgot_password,
    :reset_password,
    :logout,
    :change_password
  ]

  # POST /users/send_otp
  def send_otp
    user = User.find_by(email: params[:email])
    return render json: { success: false, message: "User not found" }, status: 404 unless user

    otp = rand(100000..999999).to_s
    user.update!(otp: otp, otp_sent_at: Time.current)

    render json: { success: true, message: "OTP sent successfully" }
  end

  # POST /users/verify_otp
  def verify_otp
    user = User.find_by(email: params[:email])

    if user&.otp == params[:otp] && user.otp_sent_at > 5.minutes.ago
      otp_token = SecureRandom.hex(16)
      user.update!(otp: nil, otp_sent_at: nil, otp_token: otp_token, otp_token_sent_at: Time.current)

      render json: { success: true, otp_token: otp_token }
    else
      render json: { success: false, message: "Invalid or expired OTP" }, status: :unauthorized
    end
  end

   # POST /users/change_password
  def change_password
    user = User.find_by(id: params[:user_id])

    unless user
      return render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end

    unless user.valid_password?(params[:current_password])
      return render json: {
        success: false,
        message: "Current password is incorrect"
      }, status: :unprocessable_entity
    end

    if params[:new_password].blank?
      return render json: {
        success: false,
        message: "New password can't be blank"
      }, status: :unprocessable_entity
    end

    if params[:new_password] != params[:new_password_confirmation]
      return render json: {
        success: false,
        message: "New password confirmation does not match"
      }, status: :unprocessable_entity
    end

    if user.update(
      password: params[:new_password],
      password_confirmation: params[:new_password_confirmation]
    )
      render json: {
        success: true,
        message: "Password changed successfully"
      }, status: :ok
    else
      render json: {
        success: false,
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # POST /users/forgot_password
  def forgot_password
    user = User.find_by(email: params[:email])

    return render json: { success: false, message: "User not found" }, status: :not_found unless user

    otp = rand(100000..999999).to_s
    user.update!(otp: otp, otp_sent_at: Time.current)

    UserMailer.send_otp(user).deliver_now

    render json: {
      success: true,
      message: "OTP sent to your email for password reset"
    }
  end


  # POST /users/reset_password
  def reset_password
    user = User.find_by(otp_token: params[:otp_token])

    unless user && user.otp_token_sent_at > 10.minutes.ago
      return render json: {
        success: false,
        message: "Invalid or expired token"
      }, status: :unauthorized
    end

    if params[:new_password].blank?
      return render json: {
        success: false,
        message: "Password can't be blank"
      }, status: :unprocessable_entity
    end

    if params[:new_password] != params[:new_password_confirmation]
      return render json: {
        success: false,
        message: "Password confirmation does not match"
      }, status: :unprocessable_entity
    end

    if user.update(password: params[:new_password], password_confirmation: params[:new_password_confirmation])
      user.update!(otp_token: nil, otp_token_sent_at: nil)

      render json: {
        success: true,
        message: "Password reset successfully"
      }
    else
      render json: {
        success: false,
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  
  # POST /users/sign_in
  def create
    user = User.find_by(email: params.dig(:user, :email))

    unless user&.valid_password?(params.dig(:user, :password))
      return render json: {
        success: false,
        message: "Invalid email or password"
      }, status: :unauthorized
    end

    puts "User Agent: #{request.user_agent}"
    puts "IP Address: #{request.remote_ip}"
    puts "Location: #{request.location.inspect}"

    browser = Browser.new(request.user_agent)

    user.login_activities.update_all(is_current: false)

    user.login_activities.create!(
      device: "#{browser.name} / #{browser.platform.name}",
      ip_address: request.remote_ip,
      location: request.location&.city || "Unknown",
      login_time: Time.current,
      is_current: true
    )

    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first

    render json: {
      success: true,
      message: "Login successful",
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role
      },
      token: token
    }, status: :ok
  end

  # POST /users/password_login
  def password_login
    user = User.find_by(otp_token: params[:otp_token])

    if user&.valid_password?(params[:password])
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
      user.update!(otp_token: nil, otp_token_sent_at: nil)

      render json: {
        success: true,
        message: "Logged in successfully",
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role
        },
        token: token
      }
    else
      render json: { success: false, message: "Invalid password or OTP token" }, status: :unauthorized
    end
  end

  def logout
    user = User.find_by(id: params[:user_id])

    if user.present?
      render json: {
        success: true,
        message: "Logged out successfully"
      }, status: :ok
    else
      render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end
  end
end
