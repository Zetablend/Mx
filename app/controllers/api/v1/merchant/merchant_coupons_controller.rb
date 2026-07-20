class Api::V1::Merchant::MerchantCouponsController < ApplicationController
  skip_before_action :authenticate_request
  before_action :set_coupon,
                only: [:show, :update, :destroy]

  rescue_from StandardError,
              with: :handle_internal_error


  ###################################
  # Coupon Statistics
  ###################################

  def stats
    render json: {
      success: true,
      data: {
        total_coupons: MerchantCoupon.count,
        active_coupons:
          MerchantCoupon.active.count,
        expiring_soon:
          MerchantCoupon.expiring_soon.count,
        revenue:
          MerchantCoupon.sum(:revenue)
      }
    }
  rescue
    render json: {
      success: false,
      message: "Statistics unavailable"
    }, status: :unprocessable_entity
  end


  ###################################
  # Coupons List
  ###################################

  def index
    coupons = MerchantCoupon.all

    if coupons.present?
      render json: {
        success: true,
        data: coupons.map do |coupon|
          {
            id: coupon.id,
            title: coupon.title,
            code: coupon.coupon_code,
            category: coupon.category,
            discount:
              discount_value(coupon),
            status: coupon.status,
            expiry: coupon.valid_till
          }
        end
      }
    else
      render json: {
        success: false,
        message: "No coupons found"
      }, status: :not_found
    end
  end


  ###################################
  # Create Coupon
  ###################################

  def create
    coupon =
      MerchantCoupon.new(coupon_params)

    if coupon.save
      render json: {
        success: true,
        message:
          "Coupon created successfully",
        data:
          coupon_response(coupon)
      }, status: :created
    else
      render json: {
        success: false,
        message:
          coupon.errors.full_messages.join(", ")
      }, status: :unprocessable_entity
    end
  end


  ###################################
  # Coupon Details
  ###################################

  def show
    return coupon_not_found unless @coupon

    render json: {
      success: true,
      data: {
        coupon_id:
          @coupon.coupon_id,
        title:
          @coupon.title,
        couponCode:
          @coupon.coupon_code,
        category:
          @coupon.category,
        discountType:
          @coupon.discount_type,
        discountValue:
          @coupon.discount_value,
        validFrom:
          @coupon.valid_from,
        validTill:
          @coupon.valid_till,
        usage_limit:
          @coupon.usage_limit,
        status:
          @coupon.status
      }
    }
  end


  ###################################
  # Update Coupon
  ###################################

  def update
    return coupon_not_found unless @coupon

    if @coupon.update(coupon_params)
      render json: {
        success: true,
        message:
          "Coupon updated successfully",
        data: {
          coupon_id:
            @coupon.coupon_id
        }
      }
    else
      render json: {
        success: false,
        message:
          @coupon.errors.full_messages.join(", ")
      }, status: :unprocessable_entity
    end
  end


  ###################################
  # Delete Coupon
  ###################################

  def destroy
    return coupon_not_found unless @coupon

    if @coupon.destroy
      render json: {
        success: true,
        message:
          "Coupon deleted successfully"
      }
    else
      render json: {
        success: false,
        message:
          "Coupon already removed"
      }, status: :unprocessable_entity
    end
  end


  private

  def set_coupon
    @coupon =
      MerchantCoupon.find_by(
        coupon_id:
        params[:coupon_id]
      )
  end


  def coupon_params
    params.permit(
      :title,
      :couponCode,
      :category,
      :discountType,
      :discountValue,
      :validFrom,
      :validTill,
      :status,
      :usage_limit,
      :revenue,
      :merchant_id
    ).transform_keys do |key|

      {
        "couponCode" =>
          "coupon_code",

        "discountType" =>
          "discount_type",

        "discountValue" =>
          "discount_value",

        "validFrom" =>
          "valid_from",

        "validTill" =>
          "valid_till"
      }[key] || key
    end
  end


  def discount_value(coupon)
    if coupon.discount_type ==
       "percentage"

      "#{coupon.discount_value}%"
    else
      coupon.discount_value
    end
  end


  def coupon_response(coupon)
    {
      coupon_id:
        coupon.coupon_id,

      title:
        coupon.title,

      couponCode:
        coupon.coupon_code,

      category:
        coupon.category,

      discountType:
        coupon.discount_type,

      discountValue:
        coupon.discount_value,

      validFrom:
        coupon.valid_from,

      validTill:
        coupon.valid_till,

      status:
        coupon.status
    }
  end


  def coupon_not_found
    render json: {
      success: false,
      message:
        "Coupon not found"
    }, status: :not_found
  end


  def handle_internal_error(exception)
    Rails.logger.error(
      exception.message
    )

    render json: {
      success: false,
      message:
        "Something went wrong",
      error:
        exception.message
    }, status: :internal_server_error
  end
end
