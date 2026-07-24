class CreateMerchantOffers < ActiveRecord::Migration[8.0]
  def change
    create_table :merchant_offers do |t|
      t.string :title
      t.string :subtitle
      t.string :category
      t.string :priority
      t.string :status
      t.string :banner_image
      t.integer :clicks
      t.bigint :merchant_id

      t.timestamps
    end
  end
end
