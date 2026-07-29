class CreateMerchantRedemptions < ActiveRecord::Migration[8.0]
  def change
    create_table :merchant_redemptions do |t|
      t.references :merchant, foreign_key: { to_table: :users }, null: false
      t.references :user, null: false, foreign_key: true
      t.string :redemption_id
      t.string :coupon_code
      t.string :customer_name
      t.string :customer_phone
      t.decimal :amount
      t.decimal :discount_amount
      t.decimal :final_amount
      t.integer :status
      t.text :reject_reason
      t.boolean :fraud_alert
      t.datetime :redeemed_at

      t.timestamps
    end
  end
end
