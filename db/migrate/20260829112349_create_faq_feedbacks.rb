class CreateFaqFeedbacks < ActiveRecord::Migration[8.0]
  def change
    create_table :faq_feedbacks do |t|
      t.references :faq, null: false, foreign_key: true
      t.boolean :helpful

      t.timestamps
    end
  end
end
