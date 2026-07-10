class CreateNotificationSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_settings do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.boolean :email, default: true, null: false
      t.boolean :sms, default: false, null: false
      t.boolean :push, default: true, null: false
      t.boolean :marketing, default: false, null: false
      t.boolean :coupon, default: true, null: false
      t.boolean :offers, default: true, null: false
      t.boolean :subscription_expiry, default: true, null: false
      t.boolean :order_updates, default: true, null: false

      t.timestamps
    end
  end
end
