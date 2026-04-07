class PaymentOption < ApplicationRecord
    has_one_attached :qr_image
    validates :name, :provider, presence: true
end
