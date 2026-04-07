class CreateOffers < ActiveRecord::Migration[8.0]
  def change
    create_table :offers do |t|
      t.string :title
      t.text :description
      t.string :discount_type
      t.decimal :value
      t.integer :category_id
      t.date :start_date
      t.date :end_date
      t.boolean :status

      t.timestamps
    end
  end
end
