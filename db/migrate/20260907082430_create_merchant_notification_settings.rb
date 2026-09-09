class CreateMerchantNotificationSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :merchant_notification_settings do |t|
      t.integer :merchant_id
      t.boolean :email_alerts
      t.boolean :push_notifications
      t.boolean :sms_notifications
      t.boolean :fraud_alerts
      t.boolean :campaign_reports

      t.timestamps
    end
      add_index :merchant_notification_settings, :merchant_id, unique: true
  end
end
