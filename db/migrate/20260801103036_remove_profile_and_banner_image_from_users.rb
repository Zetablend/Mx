class RemoveProfileAndBannerImageFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :profile_image, :string
    remove_column :users, :banner_image, :string
  end
end
