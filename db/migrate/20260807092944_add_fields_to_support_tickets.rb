class AddFieldsToSupportTickets < ActiveRecord::Migration[8.0]
  def change
    add_column :support_tickets, :ticket_number, :string
    add_column :support_tickets, :description, :text
    add_column :support_tickets, :priority, :string
    add_column :support_tickets, :ticket_type, :string
    add_column :support_tickets, :assigned_to, :string
  end
end
