class CouponRedemption < ApplicationRecord
    belongs_to :coupon
    belongs_to :user, optional: true

    validates :redeemed_at, presence: true
end
