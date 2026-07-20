class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable,
  #        :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

    devise :database_authenticatable,
         :registerable,
         :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  # has_many :user_details, dependent: :destroy
  # has_many :restaurants, dependent: :destroy
  # has_many :categories, dependent: :destroy
  # has_many :subcategories, dependent: :destroy
  # has_many :states, dependent: :destroy
  # has_many :cities, dependent: :destroy

  has_many :coupon_redemptions
  has_many :coupons, dependent: :destroy
  has_many :user_referrals
  before_create :generate_referral_code
  after_create :apply_signup_rules
  has_many :tickets, dependent: :destroy
  has_one_attached :profile_image
  has_many :addresses, dependent: :destroy
  has_many :login_activities, dependent: :destroy
  has_one :privacy_setting, dependent: :destroy
  has_one :notification_setting, dependent: :destroy

  has_many :support_tickets,
         foreign_key: :merchant_id,
         dependent: :destroy

  has_many :notifications, dependent: :destroy

  enum :role, {
    user: 0,
    merchant: 1,
    admin: 2
  }

  def password_required?
    false
  end


  def jwt_subject
    id
  end

  def generate_otp!
    self.otp = rand.to_s[2..7] # 6-digit OTP
    self.otp_sent_at = Time.current
    save!
  end

  def otp_valid?
    otp_sent_at.present? && otp_sent_at > 10.minutes.ago
  end

  def clear_otp!
    self.otp = nil
    self.otp_sent_at = nil
    save!
  end

  def otp_expired?
    otp_sent_at.nil? || otp_sent_at < 10.minutes.ago
  end

  private
    def generate_referral_code
      self.referral_code = "REF#{SecureRandom.hex(3).upcase}"
    end
  

  def apply_signup_rules
    rule = Rule.find_by(trigger_event: "User signs up")
    return unless rule
    # Loop through voucher rules in JSON
    rule.voucher_rules.each do |vr|
      Coupon.create!(
        user_id: id,
        rule_id: rule.id,
        name: vr["name"],
        description: vr["description"],
        discount_type: vr["discount_type"],
        value: vr["value"],
        applicable_on: vr["applicable_on"],
        max_usage_per_user: vr["max_usage_per_user"],
        expiration_date: vr["expiration_date"],
        status: "Active"
      )
    end
  end

end
