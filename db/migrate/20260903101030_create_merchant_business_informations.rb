class CreateMerchantBusinessInformations < ActiveRecord::Migration[8.0]
  def change
    create_table :merchant_business_informations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :business_name
      t.string :brand_email
      t.string :gst_vat_number
      t.string :pan_tax_number
      t.string :bank_account
      t.string :phone_number

      t.timestamps
    end
  end
end
