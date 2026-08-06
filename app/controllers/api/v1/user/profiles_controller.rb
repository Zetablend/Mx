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

          def login_history
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
                  device: activity.device,
                  location: activity.location,
                  date: activity.login_time.strftime("%d %b %Y")
                }
              end
            }, status: :ok
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

          def download
            user = ::User.find_by(id: params[:user_id])

            return render json: { success: false, message: "User not found" }, status: :not_found unless user

            data = user.attributes

            export_dir = Rails.root.join("public", "exports")
            FileUtils.mkdir_p(export_dir)

            file_name = "user_data_#{user.id}.json"
            file_path = export_dir.join(file_name)

            File.write(file_path, JSON.pretty_generate(data))

            download_url = "#{request.base_url}/exports/#{file_name}"

            render json: {
              success: true,
              data: {
                download_url: download_url
              }
            }
          end
      end
    end
  end
end
