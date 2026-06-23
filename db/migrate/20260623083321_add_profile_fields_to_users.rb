class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :username, :string
    add_column :users, :dob, :date
    add_column :users, :gender, :string
    add_column :users, :profile_image, :string
  end
end
