class MerchantOffer < ApplicationRecord
  belongs_to :merchant,
             class_name: "User",
             foreign_key: :merchant_id,
             optional: true
  validates :title, presence: true
  validates :category, presence: true
  validates :priority, presence: true
  validates :status, presence: true
end
