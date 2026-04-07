class CreatePaymentOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_options do |t|
      t.string :name
      t.string :provider
      t.text :account_details
      t.string :qr_image
      t.string :status

      t.timestamps
    end
  end
end
