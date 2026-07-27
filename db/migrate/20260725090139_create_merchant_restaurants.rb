class CreateMerchantRestaurants < ActiveRecord::Migration[8.0]
  def change
    create_table :merchant_restaurants do |t|
      t.string :restaurant_id
      t.bigint :merchant_id
      t.string :restaurant_name
      t.text :description
      t.string :category
      t.string :phone
      t.string :email
      t.text :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.integer :status
      t.decimal :rating
      t.integer :total_orders
      t.decimal :monthly_revenue
      t.boolean :notifications
      t.boolean :auto_accept_orders

      t.timestamps
    end
  end
end
