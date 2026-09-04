class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.string :name
      t.string :state
      t.string :country
      t.string :image
      t.text :description
      t.boolean :is_popular
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
