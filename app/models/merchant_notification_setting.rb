class MerchantNotificationSetting < ApplicationRecord
  belongs_to :merchant, class_name: "User", foreign_key: :merchant_id
  validates :merchant_id, presence: true
end
