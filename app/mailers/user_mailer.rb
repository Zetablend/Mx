class UserMailer < ApplicationMailer
    default from: 'noreply@bytesexchange.com'

    def send_otp(user)
        @user = user
        mail(to: @user.email, subject: 'Your OTP Code')
    end
end
