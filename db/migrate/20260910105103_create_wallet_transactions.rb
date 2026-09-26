class CreateWalletTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :wallet_transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount
      t.string :transaction_type
      t.string :description

      t.timestamps
    end
      add_index :wallet_transactions, [:user_id, :transaction_type]
  end
end
