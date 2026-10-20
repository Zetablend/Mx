class AddFieldsToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :image, :string
    add_column :categories, :description, :text
    add_column :categories, :is_popular, :boolean, default: false
  end
end
