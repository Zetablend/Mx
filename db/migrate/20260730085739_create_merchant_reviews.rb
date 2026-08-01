class CreateMerchantReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :merchant_reviews do |t|
      t.string :review_id
      t.references :merchant, foreign_key: { to_table: :users }, null: true
      t.string :customer_name
      t.string :customer_email
      t.integer :rating
      t.text :comment
      t.date :review_date
      t.integer :status
      t.text :reply
      t.boolean :reported
      t.string :report_reason
      t.text :report_note

      t.timestamps
    end
  end
end
