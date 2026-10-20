class AddIsPopularToRestaurants < ActiveRecord::Migration[8.0]
  def change
    add_column :restaurants, :is_popular, :boolean
  end
end
