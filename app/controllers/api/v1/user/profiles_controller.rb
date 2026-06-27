module Api
  module V1
    module User
      class ProfilesController < ApplicationController
        skip_before_action :authenticate_request
          def login_activity
            user = ::User.find_by(id: params[:user_id])

            return render json: {
              success: false,
              message: "User not found"
            }, status: :not_found unless user

            activities = user.login_activities.order(login_time: :desc)

            render json: {
              success: true,
              data: activities.map do |activity|
                {
                  user_id: activity.user_id,
                  device: activity.device,
                  ip_address: activity.ip_address,
                  location: activity.location,
                  login_time: activity.login_time.strftime("%Y-%m-%d %H:%M"),
                  is_current: activity.is_current
                }
              end
            }
          end

          def logout_all
            user = ::User.find_by(id: params[:user_id])

            return render json: {
              success: false,
              message: "User not found"
            }, status: :not_found unless user

            user.login_activities.update_all(is_current: false)

            render json: {
              success: true,
              message: "Logged out from all devices"
            }, status: :ok
          end
      end
    end
  end
end
