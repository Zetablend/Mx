class ReferralMailer < ApplicationMailer
  def invitation_email(referral)
    @referral = referral
    @referrer = referral.referrer

    @referral_link = "#{ENV.fetch('FRONTEND_URL', 'http://localhost:3000')}/register?referral_token=#{@referral.referral_token}"

    mail(
      to: @referral.email,
      subject: "#{@referrer.name} invited you to join our platform"
    )
  end
end
