class Api::V1::User::CouponsController < ApplicationController
  skip_before_action :authenticate_request

  def index
    user_id = params[:user_id]

    unless user_id.present?
      return render json: {
        success: false,
        message: "user_id is required"
      }, status: :unprocessable_entity
    end

    coupons = Coupon.where(user_id: user_id, status: "active")
                    .where(
                      "expiration_date IS NULL OR expiration_date >= ?",
                      Date.current
                    )

    coupons = apply_search(coupons)
    coupons = apply_restaurant_filter(coupons)
    coupons = apply_category_filter(coupons)
    coupons = apply_location_filter(coupons)

    page = [params[:page].to_i, 1].max
    limit = params[:limit].present? ? params[:limit].to_i : 10
    limit = [[limit, 1].max, 100].min

    total_count = coupons.count
    total_pages = (total_count.to_f / limit).ceil

    coupons = coupons.order(id: :desc)
                     .offset((page - 1) * limit)
                     .limit(limit)

    render json: {
      success: true,
      data: coupons.map { |coupon| coupon_json(coupon) },
      pagination: {
        current_page: page,
        per_page: limit,
        total_records: total_count,
        total_pages: total_pages
      }
    }
  end

  # GET /api/v1/user/coupons/redeemed
  def redeemed
    user_id = params[:user_id]

    unless user_id.present?
      return render json: {
        success: false,
        message: "user_id is required"
      }, status: :unprocessable_entity
    end

    redemptions = CouponRedemption.where(user_id: user_id)
                                  .includes(:coupon)
                                  .order(redeemed_at: :desc)

    data = redemptions.filter_map do |redemption|
      coupon = redemption.coupon
      next unless coupon

      {
        id: coupon.id,
        title: coupon_title(coupon),
        description: coupon.description,
        restaurant: restaurant_json(coupon),
        category: category_json(coupon),
        location: redemption_location_json(redemption),
        redeemed_on: redemption.redeemed_at&.to_date
      }
    end

    render json: {
      success: true,
      data: data
    }
  end

  private

  def coupon_title(coupon)
    if coupon.discount_type.to_s.downcase == "percentage"
      "#{coupon.value}% OFF"
    else
      coupon.name.presence || "#{coupon.value} OFF"
    end
  end

  def coupon_brand(coupon)
    coupon.applicable_on.presence || coupon.rule&.name || ""
  end

  def coupon_discount(coupon)
    if coupon.discount_type.to_s.downcase == "percentage"
      "#{coupon.value}%"
    else
      coupon.value.to_s
    end
  end

  def apply_search(coupons)
    return coupons if params[:search].blank?

    term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:search])}%"

    coupons.where(
      "name LIKE :term OR description LIKE :term OR code LIKE :term",
      term: term
    )
  end

  def apply_restaurant_filter(coupons)
    return coupons if params[:restaurant_id].blank?

    coupons.where(restaurant_id: params[:restaurant_id])
  end

  def apply_category_filter(coupons)
    return coupons if params[:category].blank?

    category = params[:category]

    restaurant_ids = Restaurant.where(category_id: category).select(:id)

    coupons.where(restaurant_id: restaurant_ids)
  end

  def apply_location_filter(coupons)
    return coupons if params[:location].blank?

    location = params[:location].to_s

    # Filter by restaurant address if the location is provided as text.
    restaurant_ids = Restaurant.where(
      "address LIKE ?",
      "%#{ActiveRecord::Base.sanitize_sql_like(location)}%"
    ).select(:id)

    coupons.where(restaurant_id: restaurant_ids)
  end

  def coupon_json(coupon)
    {
      id: coupon.id,
      title: coupon_title(coupon),
      description: coupon.description,
      restaurant: restaurant_json(coupon),
      category: category_json(coupon),
      location: location_json(coupon),
      expiry_date: coupon.expiration_date
    }
  end

  def coupon_title(coupon)
    if coupon.discount_type.to_s.downcase == "percentage"
      "#{coupon.value}% OFF"
    else
      coupon.name.presence || "#{coupon.value} OFF"
    end
  end

  def restaurant_json(coupon)
    return nil unless coupon.respond_to?(:restaurant_id)

    restaurant = Restaurant.find_by(id: coupon.restaurant_id)
    return nil unless restaurant

    {
      id: restaurant.id,
      name: restaurant.name
    }
  end

  def category_json(coupon)
    return nil unless coupon.respond_to?(:restaurant_id)

    restaurant = Restaurant.find_by(id: coupon.restaurant_id)
    return nil unless restaurant

    category = Category.find_by(id: restaurant.category_id)
    return nil unless category

    {
      id: category.id,
      name: category.name
    }
  end

  def location_json(coupon)
    # A location association is not confirmed in the supplied models.
    # Return nil until the actual location relationship is available.
    nil
  end

  def redemption_location_json(redemption)
    # CouponRedemption currently stores location as a text field.
    if redemption.location.present?
      {
        id: nil,
        name: redemption.location
      }
    else
      nil
    end
  end
end

