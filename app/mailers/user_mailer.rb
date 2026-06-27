class UserMailer < ApplicationMailer
    default from: 'noreply@bytesexchange.com'

    def send_otp(user)
        @user = user
        mail(to: @user.email, subject: 'Your OTP Code')
    end

    def two_factor_otp(user, otp)
        @user = user
        @otp = otp

        mail(
        to: @user.email,
        subject: "Your Two-Factor Authentication OTP"
        )
    end
end
