class AddStatusFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :status, :string
    add_column :users, :verified, :boolean
    add_column :users, :blocked, :boolean
  end
end
