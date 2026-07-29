class MerchantLocation < ApplicationRecord
  belongs_to :merchant,
             class_name: "User",
             foreign_key: :merchant_id,
             optional: true

  before_validation :generate_location_id, on: :create

  enum :status, {
    active: 0,
    inactive: 1
  }

  validates :location_name,
            :address,
            :city,
            :state,
            :zip_code,
            :manager,
            :phone,
            presence: true

  validates :phone, uniqueness: true
  validates :location_id, uniqueness: true

  scope :search, ->(search) {
    where(
      "location_name LIKE :q OR city LIKE :q OR manager LIKE :q",
      q: "%#{search}%"
    )
  }

  scope :filter_status, ->(status) {
    where(status: statuses[status.to_s.downcase]) if status.present?
  }

  private

  def generate_location_id
    return if location_id.present?

    loop do
      self.location_id = "LOC#{SecureRandom.random_number(999999).to_s.rjust(6, '0')}"
      break unless MerchantLocation.exists?(location_id: location_id)
    end
  end
end
