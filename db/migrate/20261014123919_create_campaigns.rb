class CreateCampaigns < ActiveRecord::Migration[8.0]
  def change
    create_table :campaigns do |t|
      t.string :title
      t.string :subtitle
      t.text :description
      t.references :category, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true
      t.string :campaign_type
      t.string :discount_type
      t.decimal :discount_value
      t.integer :usage_used
      t.integer :usage_limit
      t.date :start_date
      t.date :end_date
      t.string :audience
      t.string :image
      t.json :terms

      t.timestamps
    end
  end
end
