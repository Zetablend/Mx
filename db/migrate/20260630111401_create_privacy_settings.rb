class CreatePrivacySettings < ActiveRecord::Migration[8.0]
  def change
    create_table :privacy_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :share_data_with_partners
      t.boolean :personalized_ads
      t.boolean :analytics_tracking

      t.timestamps
    end
  end
end
