class CreateCouponRedemptions < ActiveRecord::Migration[8.0]
  def change
    create_table :coupon_redemptions do |t|
      t.integer :user_id
      t.integer :coupon_id
      t.datetime :redeemed_at
      t.string :location
      t.string :remarks

      t.timestamps
    end
  end
end
