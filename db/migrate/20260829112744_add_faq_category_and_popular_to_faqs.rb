class AddFaqCategoryAndPopularToFaqs < ActiveRecord::Migration[8.0]
  def change
    add_reference :faqs, :faq_category, null: false, foreign_key: true
    add_column :faqs, :is_popular, :boolean
  end
end
