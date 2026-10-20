class Api::V1::User::RedemptionsController < ApplicationController
  skip_before_action :authenticate_request

  def index
    user_id = params[:user_id]

    unless user_id.present?
      return render json: {
        success: false,
        message: "user_id is required"
      }, status: :unprocessable_entity
    end

    redemptions = CouponRedemption
                    .includes(:coupon)
                    .where(user_id: user_id)
                    .order(redeemed_at: :desc)

    render json: {
      success: true,
      data: redemptions.map do |redemption|
        {
          id: redemption.id,
          coupon: redemption.coupon&.name,
          date: redemption.redeemed_at&.to_date
        }
      end
    }
  end

  # GET /api/v1/user/redemptions/:id?user_id=14
  def show
    unless params[:user_id].present?
      return render json: {
        success: false,
        message: "user_id is required"
      }, status: :unprocessable_entity
    end

    redemption = CouponRedemption.includes(:coupon)
                                 .find_by(id: params[:id], user_id: params[:user_id])

    unless redemption
      return render json: {
        success: false,
        message: "Redemption not found"
      }, status: :not_found
    end

    coupon = redemption.coupon

    render json: {
      success: true,
      data: {
        id: redemption.id,
        coupon: coupon && {
          id: coupon.id,
          title: coupon_title(coupon)
        },
        restaurant: coupon ? restaurant_json(coupon) : nil,
        category: coupon ? category_json(coupon) : nil,
        location: location_json(redemption),
        redeemed_on: redemption.redeemed_at&.to_date,
        remarks: redemption.remarks
      }
    }
  end

  def stats
    user_id = params[:user_id]

    unless user_id.present?
      return render json: {
        success: false,
        message: "user_id is required"
      }, status: :unprocessable_entity
    end

    redemptions = CouponRedemption.where(user_id: user_id)

    render json: {
      success: true,
      data: {
        total_redemptions: redemptions.count
      }
    }
  end

  private

  def set_user_id
    @user_id = params[:user_id]

    return if @user_id.present?

    render json: {
      success: false,
      message: "user_id is required"
    }, status: :unprocessable_entity
  end

  def coupon_title(coupon)
    if coupon.discount_type.to_s.downcase == "percentage"
      "#{coupon.value}% OFF"
    else
      coupon.name.presence || "#{coupon.value} OFF"
    end
  end

  def restaurant_json(coupon)
    restaurant = coupon.restaurant
    return nil unless restaurant

    {
      id: restaurant.id,
      name: restaurant.name
    }
  end

  def category_json(coupon)
    category = coupon.restaurant&.category
    return nil unless category

    {
      id: category.id,
      name: category.name
    }
  end

  def location_json(redemption)
    return nil if redemption.location.blank?

    {
      id: nil,
      name: redemption.location
    }
  end
end
