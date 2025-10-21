class OtpSessionsController < ApplicationController
  def new
  end

  def send_otp
    user = User.find_by(email: params[:email])
    if user
      user.generate_otp!
      UserMailer.send_otp(user).deliver_later
      redirect_to verify_otp_path(email: user.email), notice: 'OTP sent to your email'
    else
      redirect_to new_otp_session_path, alert: 'Email not found'
    end
  end

  def verify
    @user = User.find_by(email: params[:email])
  end

  def confirm_otp
    user = User.find_by(email: params[:email])
    if user && user.otp == params[:otp] && user.otp_valid?
      session[:otp_verified_user_id] = user.id
      user.clear_otp!
      redirect_to password_login_path
    else
      redirect_to verify_otp_path(email: params[:email]), alert: 'Invalid or expired OTP'
    end
  end
  
end
