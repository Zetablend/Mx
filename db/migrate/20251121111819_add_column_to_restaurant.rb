class AddColumnToRestaurant < ActiveRecord::Migration[8.0]
  def change
    add_column :restaurants, :qr_code ,:string
  end
end
