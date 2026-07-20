class MerchantCoupon < ApplicationRecord
  belongs_to :merchant, optional: true

  before_create :generate_coupon_id

  validates :title, presence: true
  validates :coupon_code,
            presence: true,
            uniqueness: true

  validates :discount_type,
            inclusion: {
              in: %w[percentage flat]
            }

  validates :discount_value,
            numericality: {
              greater_than: 0
            }

  validates :status,
            inclusion: {
              in: %w[Active Inactive]
            }

  validate :valid_date_check

  scope :active, -> {
    where(status: "Active")
  }

  scope :expiring_soon, -> {
    where(valid_till: Date.current..7.days.from_now)
  }

  private

  def generate_coupon_id
    self.coupon_id ||= "CPN#{SecureRandom.random_number(1000000)}"
  end

  def valid_date_check
    return if valid_from.blank? || valid_till.blank?

    if valid_till <= valid_from
      errors.add(
        :valid_till,
        "must be greater than validFrom"
      )
    end
  end
end
