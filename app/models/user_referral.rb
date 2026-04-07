class UserReferral < ApplicationRecord
    belongs_to :referral_plan
    belongs_to :user
    belongs_to :referred_user, class_name: "User", optional: true

    validates :referral_code, presence: true, uniqueness: true
end
