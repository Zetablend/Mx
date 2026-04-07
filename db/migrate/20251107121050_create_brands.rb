class CreateBrands < ActiveRecord::Migration[8.0]
  def change
    create_table :brands do |t|
      t.string :name
      t.text :description
      t.integer :category_id

      t.timestamps
    end
  end
end
