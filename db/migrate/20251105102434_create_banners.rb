class CreateBanners < ActiveRecord::Migration[8.0]
  def change
    create_table :banners do |t|
      t.string :title
      t.string :link
      t.string :device_type
      t.boolean :status

      t.timestamps
    end
  end
end
