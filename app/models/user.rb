class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

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
end
