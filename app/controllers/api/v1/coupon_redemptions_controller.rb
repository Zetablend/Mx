class Api::V1::CouponRedemptionsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index]

  def index
    redemptions = CouponRedemption.includes(:coupon, :user).order(redeemed_at: :desc)

    # 🔍 Optional filters
    redemptions = redemptions.where(user_id: params[:user_id]) if params[:user_id].present?
    redemptions = redemptions.where(coupon_id: params[:coupon_id]) if params[:coupon_id].present?
    if params[:start_date].present? && params[:end_date].present?
      redemptions = redemptions.where(redeemed_at: params[:start_date]..params[:end_date])
    end

    render json: redemptions.map { |r| redemption_json(r) }
  end

  private

  def redemption_json(r)
    {
      id: r.id,
      redeemed_at: r.redeemed_at.strftime("%Y-%m-%d %H:%M"),
      user: r.user ? { id: r.user.id, name: r.user.name, email: r.user.email } : nil,
      coupon: r.coupon ? { id: r.coupon.id, name: r.coupon.name, code: r.coupon.code } : nil,
      location: r.location,
      remarks: r.remarks
    }
  end
end
