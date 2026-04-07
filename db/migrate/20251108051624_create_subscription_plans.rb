class CreateSubscriptionPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :subscription_plans do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.integer :duration_days
      t.boolean :status
      t.json :features

      t.timestamps
    end
  end
end
