class AddMerchantProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :banner_image, :string
    add_column :users, :business_category, :string
    add_column :users, :address, :text
    add_column :users, :website, :string
    add_column :users, :about_business, :text
  end
end
