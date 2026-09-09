class Api::V1::Merchant::Settings::NotificationsController < ApplicationController
  skip_before_action :authenticate_request

  def show
    setting = MerchantNotificationSetting.find_or_create_by!(
      merchant_id: params[:user_id]
    )

    render json: {
      success: true,
      data: {
        emailAlerts: setting.email_alerts,
        pushNotifications: setting.push_notifications,
        smsNotifications: setting.sms_notifications,
        fraudAlerts: setting.fraud_alerts,
        campaignReports: setting.campaign_reports
      }
    }
  end

  def update
    setting = MerchantNotificationSetting.find_or_create_by!(
      merchant_id: params[:user_id]
    )

    setting.update!(notification_setting_params)

    render json: {
      success: true,
      message: "Notification settings updated successfully"
    }
  end

  private

  def notification_setting_params
    params.permit(
      :emailAlerts,
      :pushNotifications,
      :smsNotifications,
      :fraudAlerts,
      :campaignReports
    ).to_h.transform_keys do |key|
      key.underscore
    end
  end
end
