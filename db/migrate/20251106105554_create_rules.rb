class CreateRules < ActiveRecord::Migration[8.0]
  def change
    create_table :rules do |t|
      t.string :name
      t.string :loyalty_program_type
      t.string :trigger_event
      t.string :stamp_type
      t.integer :stamp_expiration
      t.string :target_audience
      t.string :event_types
      t.json :voucher_rules
      t.text :summary

      t.timestamps
    end
  end
end
