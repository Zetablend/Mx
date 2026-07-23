# app/controllers/api/v1/merchant/redemptions_controller.rb

class Api::V1::Merchant::RedemptionsController < ApplicationController
  def latest
    merchant = current_user

    return render json: {
      success: false,
      message: "User not found"
    }, status: :unauthorized unless merchant

    redemptions =
      CouponRedemption
        .includes(:user, :coupon)
        .joins(:coupon)
        .where(coupons: { user_id: merchant.id })
        .order(redeemed_at: :desc)
        .limit(10)

    if redemptions.blank?
      return render json: {
        success: false,
        message: "No redemptions available"
      }, status: :ok
    end

    data =
      redemptions.map do |redemption|
        {
          customer_name: redemption.user&.name || "N/A",
          coupon_code: redemption.coupon&.code,
          amount: redemption.coupon&.value.to_f
        }
      end

    render json: {
      success: true,
      data: data
    }, status: :ok
  end
end