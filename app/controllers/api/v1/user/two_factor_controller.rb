# app/controllers/api/v1/user/two_factor_controller.rb

module Api
  module V1
    module User
      class TwoFactorController < ApplicationController
        skip_before_action :authenticate_request

        # POST /api/v1/user/2fa/enable
        def enable
          user = ::User.find_by(id: params[:user_id])

          return render json: {
            success: false,
            message: "User not found"
          }, status: :not_found unless user

          otp = rand(100000..999999).to_s

          user.update!(
            otp: otp,
            otp_sent_at: Time.current
          )

          UserMailer.two_factor_otp(user, otp).deliver_now

          render json: {
            success: true,
            message: "OTP sent to your email"
          }
        end
        # POST /api/v1/user/2fa/verify
        def verify
          user = ::User.find_by(id: params[:user_id])

          return render json: {
            success: false,
            message: "User not found"
          }, status: :not_found unless user

          if user.otp != params[:otp]
            return render json: {
              success: false,
              message: "Invalid OTP"
            }, status: :unprocessable_entity
          end

          if user.otp_sent_at < 10.minutes.ago
            return render json: {
              success: false,
              message: "OTP has expired"
            }, status: :unprocessable_entity
          end

          user.update!(
            two_factor_enabled: true,
            otp: nil,
            otp_sent_at: nil
          )

          render json: {
            success: true,
            message: "Two-Factor Authentication enabled successfully"
          }
        end

        # POST /api/v1/user/2fa/disable
        def disable
          user = ::User.find_by(id: params[:user_id])

          return render json: {
            success: false,
            message: "User not found"
          }, status: :not_found unless user

          unless user.valid_password?(params[:password])
            return render json: {
              success: false,
              message: "Incorrect password"
            }, status: :unprocessable_entity
          end

          user.update!(
            two_factor_enabled: false,
            otp: nil,
            otp_sent_at: nil
          )

          render json: {
            success: true,
            message: "2FA disabled"
          }
        end
      end
    end
  end
end
