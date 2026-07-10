module Api
  module V1
    module User
      class PrivacyController < ApplicationController
        skip_before_action :authenticate_request

        def show
          user = ::User.find_by(id: params[:user_id])

          return render json: {
            success: false,
            message: "User not found"
          }, status: :not_found unless user

          privacy = user.privacy_setting || user.create_privacy_setting

          render json: {
            success: true,
            data: {
              share_data_with_partners: privacy.share_data_with_partners,
              personalized_ads: privacy.personalized_ads,
              analytics_tracking: privacy.analytics_tracking
            }
          }
        end

        def update
          user = ::User.find_by(id: params[:user_id])

          return render json: {
            success: false,
            message: "User not found"
          }, status: :not_found unless user

          privacy = user.privacy_setting || user.create_privacy_setting

          if privacy.update(privacy_params)
            render json: {
              success: true
            }
          else
            render json: {
              success: false,
              errors: privacy.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        private

        def privacy_params
          params.permit(
            :share_data_with_partners,
            :personalized_ads,
            :analytics_tracking
          )
        end
      end
    end
  end
end
