class WalletTransaction < ApplicationRecord
  belongs_to :user

  validates :amount, presence: true, numericality: { greater_than: 0 }

  validates :transaction_type,
            presence: true,
            inclusion: { in: %w[earned redeemed] }
end
