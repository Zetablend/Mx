class MerchantRestaurant < ApplicationRecord
  belongs_to :merchant,
             class_name: "User",
             foreign_key: :merchant_id,
             optional: true

  enum :status, {
    active: 0,
    inactive: 1
  }

  before_create :generate_restaurant_id

  validates :restaurant_name,
            :category,
            :phone,
            :email,
            :city,
            :state,
            presence: true

  scope :search, ->(value){
    where(
      "restaurant_name ILIKE ? OR city ILIKE ? OR category ILIKE ?",
      "%#{value}%",
      "%#{value}%",
      "%#{value}%"
    )
  }

  scope :filter_status, ->(status){
    where(status: statuses[status.downcase])
  }

  scope :filter_city, ->(city){
    where(city: city)
  }

  private

  def generate_restaurant_id
    self.restaurant_id ||= "RST#{SecureRandom.random_number(999999)}"
  end
end
