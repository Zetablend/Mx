class MerchantDeal < ApplicationRecord
  belongs_to :merchant,
             class_name: "User",
             foreign_key: :merchant_id,
             optional: true

  has_one_attached :banner_image

  validates :title,
            presence: true

  validates :category,
            presence: true

  validates :discount_type,
            presence: true

  validates :discount_value,
            presence: true,
            numericality: {
              greater_than: 0
            }

  validates :start_date,
            presence: true

  validates :end_date,
            presence: true

  validates :status,
            presence: true

  validates :deal_code,
            uniqueness: true

  validate :end_date_after_start

  before_validation :generate_deal_code,
                    on: :create

  scope :active, -> {
    where(status: "Active")
  }

  scope :inactive, -> {
    where(status: "Inactive")
  }

  scope :draft, -> {
    where(status: "Draft")
  }

  scope :expired, -> {
    where("end_date < ?", Date.today)
  }

  scope :search, ->(text) {
    where(
      "LOWER(title) LIKE :search
      OR LOWER(description) LIKE :search
      OR LOWER(category) LIKE :search
      OR LOWER(deal_code) LIKE :search",
      search: "%#{text.downcase}%"
    )
  }

  scope :filter_status, ->(status) {
    where(status: status)
  }

  scope :filter_category, ->(category) {
    where(category: category)
  }

  private

  def generate_deal_code
    return if deal_code.present?

    loop do
      self.deal_code = "DL#{SecureRandom.random_number(999999).to_s.rjust(6, '0')}"
      break unless MerchantDeal.exists?(deal_code: deal_code)
    end
  end

  def end_date_after_start
    return if start_date.blank? || end_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end
