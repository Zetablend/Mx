class AddPreferencesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :language, :string
    add_column :users, :currency, :string
    add_column :users, :location, :string
  end
end
