class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :price
      t.integer :stock
      t.text :description
      t.references :product_category, foreign_key: true
      t.timestamps
    end
  end
end
