class ReferralPlan < ApplicationRecord
    has_many :user_referrals, dependent: :destroy
    validates :name, :reward_type, :reward_value, presence: true
end
