class CreateMerchantCoupons < ActiveRecord::Migration[8.0]
  def change
    create_table :merchant_coupons do |t|
      t.string :coupon_id
      t.string :title
      t.string :coupon_code
      t.string :category
      t.string :discount_type
      t.decimal :discount_value
      t.date :valid_from
      t.date :valid_till
      t.string :status
      t.integer :usage_limit
      t.decimal :revenue
      t.bigint :merchant_id

      t.timestamps
    end
  end
end
