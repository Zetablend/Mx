class Api::V1::UserReferralsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :destroy, :update, :stats, :referral_code]

  def index
    user = User.find_by(id: params[:user_id])

    unless user
      return render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end

    referrals = Referral.where(referrer_user_id: user.id).order(created_at: :desc)

    render json: {
      success: true,
      data: referrals.map do |referral|
        referred_user = referral.referred_user

        {
          id: referral.id,
          name: referred_user&.name,
          email: referred_user&.email || referral.email,
          joined_date: referred_user&.created_at&.to_date,
          status: referral.status.to_s.downcase == "completed" ? "Completed" : "Pending",
          reward: referral.reward || 0
        }
      end
    }
  end

  def stats
    user = User.find_by(id: params[:user_id])

    unless user
      return render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end

    referrals = Referral.where(referrer_user_id: user.id)
    completed = referrals.where(status: "completed")

    render json: {
      success: true,
      data: {
        total_referrals: referrals.count,
        total_earned: completed.sum(:reward),
        pending_rewards: referrals.where.not(status: "completed").count,
        wallet_earnings: completed.sum(:reward)
      }
    }
  end

  def referral_code
    user = User.find_by(id: params[:user_id])

    unless user
      return render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end

    render json: {
      success: true,
      data: {
        code: user.referral_code
      }
    }
  end

  def update
    referral = UserReferral.find(params[:id])
    if referral.update(status: params[:status])
      render json: { message: "Referral status updated", referral: referral }
    else
      render json: { errors: referral.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    referral = UserReferral.find(params[:id])
    referral.destroy
    render json: { message: "Referral deleted successfully" }
  end

  private

  def referral_json(r)
    {
      id: r.id,
      referral_code: r.referral_code,
      status: r.status,
      referrer: r.user ? { id: r.user.id, name: r.user.name, email: r.user.email } : nil,
      referred_user: r.referred_user ? { id: r.referred_user.id, name: r.referred_user.name, email: r.referred_user.email } : nil,
      plan_name: r.referral_plan&.name,
      created_at: r.created_at.strftime("%Y-%m-%d %H:%M")
    }
  end
end
