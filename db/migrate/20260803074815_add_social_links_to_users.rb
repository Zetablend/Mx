class AddSocialLinksToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :instagram, :string
    add_column :users, :facebook, :string
    add_column :users, :linkedin, :string
    add_column :users, :youtube, :string
  end
end
