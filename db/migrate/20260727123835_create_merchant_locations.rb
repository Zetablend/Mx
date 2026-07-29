class CreateMerchantLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :merchant_locations do |t|
      t.string :location_id
      t.references :merchant, foreign_key: { to_table: :users }, null: true
      t.string :location_name
      t.text :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :manager
      t.string :phone
      t.integer :status, default: 0
      t.integer :total_staff, default: 0

      t.timestamps
    end
    add_index :merchant_locations, :location_id, unique: true
    add_index :merchant_locations, :phone, unique: true
  end
end
