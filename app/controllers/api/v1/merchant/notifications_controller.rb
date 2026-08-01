class Api::V1::Merchant::NotificationsController < ApplicationController
  skip_before_action :authenticate_request

  def stats
    notifications = MerchantNotification.where(merchant_id: params[:user_id])

    render json: {
      success: true,
      data: {
        totalNotifications: notifications.count,
        sentToday: notifications.where(sent_at: Date.today.all_day).count,
        scheduledNotifications: notifications.scheduled.count,
        failedNotifications: notifications.failed.count
      }
    }
  end

  def filter
    notifications = MerchantNotification.where(merchant_id: params[:user_id])

    notifications = notifications.where("title LIKE ?", "%#{params[:search]}%") if params[:search].present?
    notifications = notifications.where(notification_type: params[:type]) if params[:type].present?
    notifications = notifications.where(status: params[:status].downcase) if params[:status].present?

    render json: {
      success: true,
      data: notifications
    }
  end

  def list
    notifications = MerchantNotification.where(merchant_id: params[:user_id])

    render json: {
      success: true,
      data: notifications.map do |n|
        {
          notification_id: n.notification_id,
          title: n.title,
          message: n.message,
          type: n.notification_type,
          status: n.status.titleize,
          audience: n.audience,
          sentAt: n.sent_at
        }
      end
    }
  end

  def show
    notification = MerchantNotification.find_by!(
      merchant_id: params[:user_id],
      notification_id: params[:id]
    )

    render json: {
      success: true,
      data: {
        notification_id: notification.notification_id,
        title: notification.title,
        message: notification.message,
        type: notification.notification_type,
        status: notification.status.titleize,
        audience: notification.audience,
        sentAt: notification.sent_at,
        deliveryCount: notification.delivery_count,
        openedCount: notification.opened_count,
        clickedCount: notification.clicked_count
      }
    }
  end

  def send_notification
    notification = MerchantNotification.create!(
      merchant_id: params[:user_id],
      title: params[:title],
      message: params[:message],
      notification_type: params[:type],
      audience: params[:audience],
      schedule_type: "instant",
      status: :sent,
      sent_at: Time.current
    )

    render json: {
      success: true,
      message: "Notification sent successfully",
      data: {
        notification_id: notification.notification_id,
        title: notification.title,
        status: "Sent"
      }
    }
  end

  def schedule
    notification = MerchantNotification.create!(
      merchant_id: params[:user_id],
      title: params[:title],
      message: params[:message],
      notification_type: params[:type],
      audience: params[:audience],
      schedule_type: "scheduled",
      scheduled_at: params[:scheduledAt],
      status: :scheduled
    )

    render json: {
      success: true,
      message: "Notification scheduled successfully",
      data: {
        notification_id: notification.notification_id,
        status: "Scheduled",
        scheduledAt: notification.scheduled_at
      }
    }
  end

  private

  def notification_params
    params.permit(
      :title,
      :message,
      :type,
      :audience,
      :scheduleType,
      :scheduledAt,
      :user_id
    )
  end
end
