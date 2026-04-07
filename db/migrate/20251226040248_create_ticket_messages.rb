class CreateTicketMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :ticket_messages do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
