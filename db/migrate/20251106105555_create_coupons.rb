class CreateCoupons < ActiveRecord::Migration[8.0]
  def change
    create_table :coupons do |t|
      t.string :code
      t.string :name
      t.string :description
      t.string :discount_type
      t.decimal :value
      t.string :applicable_on
      t.integer :max_usage_per_user
      t.date :expiration_date
      t.string :status
      t.integer :user_id
      t.integer :rule_id

      t.timestamps
    end
  end
end
