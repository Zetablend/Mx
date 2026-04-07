class CreateReferralPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :referral_plans do |t|
      t.string :name
      t.text :description
      t.string :reward_type
      t.decimal :reward_value
      t.date :expiration_date
      t.string :status

      t.timestamps
    end
  end
end
