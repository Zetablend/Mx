class Api::V1::UserReferralsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :destroy, :update]

  def index
    referrals = UserReferral.includes(:user, :referred_user, :referral_plan).order(created_at: :desc)
    render json: referrals.map { |r| referral_json(r) }
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
