class Api::V1::User::ReferralsController < ApplicationController
    skip_before_action :authenticate_request

  def index
    user = User.find_by(id: params[:user_id])

    unless user
      return render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end

    referrals = Referral.where(referrer_user_id: user.id)

    completed_referrals = referrals.where(status: "completed")

    render json: {
      success: true,
      data: {
        total_referrals: completed_referrals.count,
        earned: completed_referrals.sum(:reward)
      }
    }
  end

  def invite
    user = User.find_by(id: params[:user_id])

    unless user
      return render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end

    email = params[:email].to_s.strip.downcase

    if email.blank?
      return render json: {
        success: false,
        message: "Email is required"
      }, status: :unprocessable_entity
    end

    if user.email.to_s.downcase == email
      return render json: {
        success: false,
        message: "You cannot refer yourself"
      }, status: :unprocessable_entity
    end

    existing_user = User.find_by(email: email)

    if existing_user
      return render json: {
        success: false,
        message: "This user is already registered"
      }, status: :unprocessable_entity
    end

    existing_referral = Referral.find_by(
      referrer_user_id: user.id,
      email: email
    )

    if existing_referral
      return render json: {
        success: false,
        message: "This email has already been invited"
      }, status: :unprocessable_entity
    end

    referral = Referral.create!(
      referrer_user_id: user.id,
      email: email,
      referral_token: SecureRandom.hex(16),
      status: "invited",
      reward: 0
    )

    ReferralMailer.invitation_email(referral).deliver_later

    render json: {
      success: true,
      message: "Invitation sent",
      data: {
        referral_id: referral.id,
        referral_token: referral.referral_token
      }
    }
  end
end
