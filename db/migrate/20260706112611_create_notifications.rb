class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :message
      t.string :notification_type
      t.boolean :is_read
      t.string :action_url
      t.json :metadata

      t.timestamps
    end
    add_index :notifications, :notification_type
    add_index :notifications, :is_read
  end
end
