class CreateLoginActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :login_activities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :device
      t.string :ip_address
      t.string :location
      t.datetime :login_time
      t.boolean :is_current, default: false

      t.timestamps
    end
  end
end
