class AddOtpTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :otp_token, :string
    add_column :users, :otp_token_sent_at, :datetime
  end
end
