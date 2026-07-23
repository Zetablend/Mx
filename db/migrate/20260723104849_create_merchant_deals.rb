class CreateMerchantDeals < ActiveRecord::Migration[8.0]
  def change
    create_table :merchant_deals do |t|
      t.bigint :merchant_id
      t.string :deal_code
      t.string :title
      t.text :description
      t.string :category
      t.string :discount_type
      t.decimal :discount_value
      t.date :start_date
      t.date :end_date
      t.string :status
      t.integer :views
      t.integer :clicks
      t.decimal :revenue

      t.timestamps
    end
      add_index :merchant_deals, :deal_code, unique: true
      add_index :merchant_deals, :status
      add_index :merchant_deals, :category
  end
end
