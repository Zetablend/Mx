module Api
  module V1
    module User
      class NotificationsController < ApplicationController
        skip_before_action :authenticate_request

        before_action :set_notification_setting

        # GET /api/v1/user/notifications?user_id=1
        def show
          render json: {
            success: true,
            data: {
              email: @notification_setting.email,
              sms: @notification_setting.sms,
              push: @notification_setting.push,
              marketing: @notification_setting.marketing,
              coupon: @notification_setting.coupon,
              offers: @notification_setting.offers,
              subscription_expiry: @notification_setting.subscription_expiry,
              order_updates: @notification_setting.order_updates
            }
          }, status: :ok
        end

        # GET /api/v1/user/notifications/feed
        def feed
          page = params[:page].present? ? params[:page].to_i : 1
          limit = params[:limit].present? ? params[:limit].to_i : 10

          notifications = @user.notifications.order(created_at: :desc)

          if params[:is_read].present?
            notifications = notifications.where(is_read: ActiveModel::Type::Boolean.new.cast(params[:is_read]))
          end

          if params[:type].present? && params[:type] != "all"
            notifications = notifications.where(notification_type: params[:type])
          end

          total = notifications.count

          notifications = notifications.offset((page - 1) * limit).limit(limit)

          render json: {
            success: true,
            data: notifications.map { |notification|
              {
                id: notification.id,
                title: notification.title,
                message: notification.message,
                type: notification.notification_type,
                is_read: notification.is_read,
                created_at: notification.created_at,
                action: {
                  url: notification.action_url
                }
              }
            },
            pagination: {
              page: page,
              limit: limit,
              total: total
            }
          }, status: :ok
        end

        # PATCH /api/v1/user/notifications/:id/read
        def mark_as_read
          @notification = @user.notifications.find_by(id: params[:id])

          return render json: {
            success: false,
            message: "Notification not found"
          }, status: :not_found unless @notification

          @notification.update(is_read: true)

          render json: {
            success: true,
            message: "Notification marked as read"
          }, status: :ok
        end

        # PATCH /api/v1/user/notifications/read-all
        def mark_all_as_read
          @user.notifications.where(is_read: false).update_all(is_read: true)

          render json: {
            success: true,
            message: "All notifications marked as read"
          }, status: :ok
        end

        # DELETE /api/v1/user/notifications/:id
        def destroy
          @notification = @user.notifications.find_by(id: params[:id])

          return render json: {
            success: false,
            message: "Notification not found"
          }, status: :not_found unless @notification

          @notification.destroy

          render json: {
            success: true,
            message: "Notification deleted successfully"
          }, status: :ok
        end

        # GET /api/v1/user/notifications/unread-count
        def unread_count
          render json: {
            success: true,
            data: {
              unread: @user.notifications.where(is_read: false).count
            }
          }, status: :ok
        end
        # PUT /api/v1/user/notifications?user_id=1
        def update
          if @notification_setting.update(notification_params)
            render json: {
              success: true,
              message: "Notification settings updated"
            }, status: :ok
          else
            render json: {
              success: false,
              errors: @notification_setting.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        private

        def set_notification_setting
          @user = ::User.find_by(id: params[:user_id])

          return render json: {
            success: false,
            message: "User not found"
          }, status: :not_found unless @user

          @notification_setting = @user.notification_setting

          unless @notification_setting
            @notification_setting = @user.create_notification_setting(
              email: true,
              sms: false,
              push: true,
              marketing: false,
              coupon: true,
              offers: true,
              subscription_expiry: true,
              order_updates: true
            )
          end
        end

        def notification_params
          params.permit(
            :email,
            :sms,
            :push,
            :marketing,
            :coupon,
            :offers,
            :subscription_expiry,
            :order_updates
          )
        end

        def set_user
          @user = ::User.find_by(id: params[:user_id])

          return render json: {
            success: false,
            message: "User not found"
          }, status: :not_found unless @user
        end

        def set_notification
          @notification = @user.notifications.find_by(id: params[:id])

          return render json: {
            success: false,
            message: "Notification not found"
          }, status: :not_found unless @notification
        end
      end
    end
  end
end
