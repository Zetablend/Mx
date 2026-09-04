class CreateReferrals < ActiveRecord::Migration[8.0]
  def change
    create_table :referrals do |t|
      t.integer :referrer_user_id, null: false
      t.integer :referred_user_id
      t.string :email, null: false
      t.string :referral_token, null: false
      t.string :status, default: "invited", null: false
      t.decimal :reward, precision: 10, scale: 2, default: 0

      t.timestamps
    end

    add_index :referrals, :referral_token, unique: true
    add_index :referrals, :referrer_user_id
    add_index :referrals, :referred_user_id
    add_index :referrals, [:referrer_user_id, :email]
  end
end
