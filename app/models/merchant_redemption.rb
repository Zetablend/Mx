class MerchantRedemption < ApplicationRecord
  belongs_to :merchant, class_name: "User"
  belongs_to :user
  
  enum :status, {
    pending: 0,
    completed: 1,
    rejected: 2
  }

  before_create :generate_redemption_id

  validates :coupon_code,
            :customer_name,
            :amount,
            presence: true

  scope :search, ->(query) {
    where(
      "coupon_code LIKE :q
      OR customer_name LIKE :q
      OR redemption_id LIKE :q",
      q: "%#{query}%"
    )
  }

  scope :status_filter, ->(status) {
    where(status: statuses[status.downcase]) if status.present?
  }

  private

  def generate_redemption_id
    self.redemption_id ||= "RED#{SecureRandom.random_number(999999)}"
  end
end
