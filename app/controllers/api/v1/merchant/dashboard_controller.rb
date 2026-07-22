class Api::V1::Merchant::DashboardController < ApplicationController
  def stats
    merchant = current_user

    return render json: {
      success: false,
      message: "User not found"
    }, status: :unauthorized unless merchant

    merchant_coupons =
      Coupon.where(user_id: merchant.id)

    total_coupons =
      merchant_coupons.count

    active_offers =
      Offer
        .where(status: true)
        .where(
          "start_date <= ? AND end_date >= ?",
          Date.current,
          Date.current
        )
        .count

    redemptions =
      CouponRedemption
        .joins(:coupon)
        .where(
          coupons: {
            user_id: merchant.id
          }
        )

    total_redemptions =
      redemptions.count

    revenue_generated =
      redemptions.sum("coupons.value")

    render json: {
      success: true,
      data: {
        total_coupons: total_coupons,
        active_offers: active_offers,
        total_redemptions: total_redemptions,
        revenue_generated: revenue_generated
      }
    }
  end

  def coupon_usage
    merchant = current_user

    usage =
      CouponRedemption
        .joins(:coupon)
        .where(
          coupons: {
            user_id: merchant.id
          }
        )
        .group(
          "DAYNAME(coupon_redemptions.created_at)"
        )
        .count

    if usage.blank?
      render json: {
        success: false,
        message: "No analytics found"
      }, status: :ok

      return
    end

    data =
      usage.map do |day, count|
        {
          day: day.first(3),
          usage: count
        }
      end

    render json: {
      success: true,
      data: data
    }, status: :ok
  end

  def revenue_analytics
    merchant = current_user

    return render json: {
      success: false,
      message: "User not found"
    }, status: :unauthorized unless merchant

    revenue =
      CouponRedemption
        .joins(:coupon)
        .where(coupons: { user_id: merchant.id })
        .group("MONTHNAME(coupon_redemptions.created_at)")
        .sum("coupons.value")

    if revenue.blank?
      return render json: {
        success: false,
        message: "Revenue data unavailable"
      }, status: :ok
    end

    data =
      revenue.map do |month, amount|
        {
          month: month.first(3),
          revenue: amount.to_f
        }
      end

    render json: {
      success: true,
      data: data
    }, status: :ok
  end

  def top_coupons
    merchant = current_user

    return render json: {
      success: false,
      message: "User not found"
    }, status: :unauthorized unless merchant

    coupons =
      Coupon
        .left_joins(:coupon_redemptions)
        .where(user_id: merchant.id)
        .group("coupons.id", "coupons.code")
        .select(
          "coupons.code AS coupon_code",
          "COUNT(coupon_redemptions.id) AS redemptions_count"
        )
        .having("COUNT(coupon_redemptions.id) > 0")
        .order("redemptions_count DESC")
        .limit(10)

    if coupons.blank?
      return render json: {
        success: false,
        message: "Coupons not found"
      }, status: :ok
    end

    data =
      coupons.map do |coupon|
        {
          coupon_code: coupon.coupon_code,
          redemptions: coupon.redemptions_count.to_i
        }
      end

    render json: {
      success: true,
      data: data
    }, status: :ok
  end

  private

  def validate_merchant
    unless current_user&.merchant?
      render json: {
        success: false,
        message: "Unauthorized access"
      }, status: :unauthorized
    end
  end

  def active_offers_count
    Offer
      .where(status: true)
      .where(
        "start_date <= ? AND end_date >= ?",
        Date.current,
        Date.current
      )
      .count
  end
end