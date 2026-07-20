module Api
  module V1
    module User
      class PreferencesController < ApplicationController
        skip_before_action :authenticate_request
        before_action :set_user

        def show
          render json: {
            success: true,
            data: {
              language: @user.language,
              currency: @user.currency,
              location: @user.location
            }
          }
        end

        def update
          if @user.update(preferences_params)
            render json: {
              success: true,
              message: "Preferences updated successfully"
            }
          else
            render json: {
              success: false,
              errors: @user.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        private

        def set_user
          @user = ::User.find_by(id: params[:user_id])

          return render json: {
            success: false,
            message: "User not found"
          }, status: :not_found unless @user
        end

        def preferences_params
          params.require(:preference)
                .permit(:language, :currency, :location)
        end
      end
    end
  end
end
