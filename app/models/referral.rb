class Referral < ApplicationRecord
  belongs_to :referrer,
             class_name: "User",
             foreign_key: :referrer_user_id

  belongs_to :referred_user,
             class_name: "User",
             optional: true

  validates :email, presence: true
  validates :referral_token, presence: true, uniqueness: true
end
