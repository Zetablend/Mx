class CreateRestaurants < ActiveRecord::Migration[8.0]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.text :description
      t.string :address
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
