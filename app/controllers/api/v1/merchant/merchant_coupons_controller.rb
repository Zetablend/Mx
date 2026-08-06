class Api::V1::Merchant::MerchantCouponsController < ApplicationController
  skip_before_action :authenticate_request
  before_action :set_coupon,
                only: [:show, :update, :destroy]
  before_action :validate_merchant

  rescue_from StandardError,
              with: :handle_internal_error


  ###################################
  # Coupon Statistics
  ###################################

  def stats
    coupons = MerchantCoupon.where(merchant_id: params[:merchant_id])

    render json: {
      success: true,
      data: {
        total_coupons: coupons.count,
        active_coupons: coupons.active.count,
        expiring_soon: coupons.expiring_soon.count,
        revenue: coupons.sum(:revenue)
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
    coupons = MerchantCoupon.where(merchant_id: params[:merchant_id])

    if coupons.present?
      render json: {
        success: true,
        data: coupons.map do |coupon|
          {
            id: coupon.id,
            coupon_id: coupon.coupon_id,
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

  ###################################
  # Coupon Analytics
  ###################################
  def analytics
    coupons = MerchantCoupon.where(merchant_id: params[:merchant_id])

    if coupons.present?
      redemptions =
        coupons.group_by { |c| c.created_at.strftime("%b") }
              .map do |month, records|
          {
            month: month,
            value: records.sum { |c| c.usage_limit.to_i }
          }
        end

      revenue =
        coupons.group_by { |c| c.created_at.strftime("%b") }
              .map do |month, records|
          {
            month: month,
            revenue: records.sum { |c| c.revenue.to_f }
          }
        end

      render json: {
        success: true,
        data: {
          redemptions: redemptions,
          revenue: revenue
        }
      }
    else
      render json: {
        success: false,
        message: "Analytics data unavailable"
      }, status: :not_found
    end
  end


  ###################################
  # Coupon Filters
  ###################################
  def filter
    coupons = MerchantCoupon.where(merchant_id: params[:merchant_id])

    coupons =
      coupons.where(category: params[:category]) if params[:category].present?

    coupons =
      coupons.where(status: params[:status]) if params[:status].present?


    if params[:search].present?
      coupons = coupons.where(
        "LOWER(title) LIKE :q OR LOWER(coupon_code) LIKE :q",
        q: "%#{params[:search].to_s.downcase}%"
      )
    end

    if coupons.present?
      render json: {
        success: true,
        data: coupons.map do |coupon|
          {
            id: coupon.id,
            title: coupon.title,
            category: coupon.category,
            status: coupon.status
          }
        end
      }
    else
      render json: {
        success: false,
        message: "No filtered coupons found"
      }, status: :not_found
    end
  end


  ###################################
  # Coupon Expiry Alerts
  ###################################
  def expiry_alerts
    alerts = []

    MerchantCoupon.where(merchant_id: params[:merchant_id])
            .where.not(valid_till: nil)
            .find_each do |coupon|
      days_left =
        (coupon.valid_till.to_date - Date.current).to_i

      next if days_left.negative?

      alert_type =
        if days_left <= 2
          "Urgent"
        elsif days_left <= 7
          "Warning"
        else
          "Normal"
        end

      alerts << {
        coupon_id: coupon.coupon_id,
        couponCode: coupon.coupon_code,
        expiryDate: coupon.valid_till,
        daysLeft: days_left,
        alertType: alert_type
      }
    end

    if alerts.present?
      render json: {
        success: true,
        data: alerts
      }
    else
      render json: {
        success: false,
        message: "No expiry alerts found"
      }, status: :not_found
    end
  end

  private

  def set_coupon
    @coupon = MerchantCoupon.find_by(
      coupon_id: params[:coupon_id],
      merchant_id: params[:merchant_id]
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

  def validate_merchant
    return if params[:merchant_id].present?

    render json: {
      success: false,
      message: "merchant_id is required"
    }, status: :unprocessable_entity
  end
end
