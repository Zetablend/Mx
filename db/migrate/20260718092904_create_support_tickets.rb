class CreateSupportTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :support_tickets do |t|
      t.references :merchant, null: false, foreign_key: { to_table: :users }
      t.string :subject
      t.string :status, default: "Open"

      t.timestamps
    end
  end
end
