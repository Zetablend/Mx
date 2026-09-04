class CreateStaffs < ActiveRecord::Migration[8.0]
  def change
    create_table :staffs do |t|
      t.string :name
      t.string :role
      t.string :permission
      t.string :status
      t.string :staff_id

      t.timestamps
    end
        add_index :staffs, :staff_id, unique: true
  end
end
