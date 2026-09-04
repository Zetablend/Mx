class MerchantBusinessInformation < ApplicationRecord
  belongs_to :user
  validates :business_name, presence: true
  validates :brand_email, presence: true
end
