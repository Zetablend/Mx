class CreateMerchantNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :merchant_notifications do |t|
      t.string :notification_id
      t.references :merchant, foreign_key: { to_table: :users }, null: true
      t.string :title
      t.text :message
      t.string :notification_type
      t.integer :status
      t.string :audience
      t.string :schedule_type
      t.datetime :scheduled_at
      t.datetime :sent_at
      t.integer :delivery_count
      t.integer :opened_count
      t.integer :clicked_count
      t.integer :failed_count

      t.timestamps
    end
  end
end
