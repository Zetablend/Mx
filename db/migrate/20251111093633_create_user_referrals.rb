class CreateUserReferrals < ActiveRecord::Migration[8.0]
  def change
    create_table :user_referrals do |t|
      t.integer :user_id
      t.integer :referred_user_id
      t.string :referral_code
      t.string :status
      t.integer :referral_plan_id

      t.timestamps
    end
  end
end
