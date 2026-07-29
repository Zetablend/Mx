class Api::V1::Merchant::MerchantRedemptionsController < ApplicationController
  skip_before_action :authenticate_request
  before_action :set_redemption, only: [:show, :verify, :reject]

  # GET /api/v1/merchant/redemptions/stats
  def stats
    redemptions = MerchantRedemption.where(merchant_id: params[:user_id])

    render json: {
      success: true,
      data: {
        totalRedemptions: redemptions.count,
        approved: redemptions.completed.count,
        rejected: redemptions.rejected.count,
        fraudAlerts: redemptions.where(fraud_alert: true).count
      }
    }
  end

  # GET /api/v1/merchant/redemptions/filter
  def filter
    redemptions = MerchantRedemption.where(merchant_id: params[:user_id])

    if params[:search].present?
      search = "%#{params[:search]}%"

      redemptions = redemptions.where(
        "coupon_code LIKE ? OR customer_name LIKE ? OR redemption_id LIKE ?",
        search,
        search,
        search
      )
    end

    if params[:status].present?
      status = params[:status].downcase

      if MerchantRedemption.statuses.key?(status)
        redemptions = redemptions.where(status: MerchantRedemption.statuses[status])
      end
    end

    page = params[:page].to_i
    page = 1 if page <= 0

    limit = params[:limit].to_i
    limit = 10 if limit <= 0

    redemptions = redemptions.order(created_at: :desc)
                             .offset((page - 1) * limit)
                             .limit(limit)

    render json: {
      success: true,
      data: redemptions.map { |r|
        {
          redemption_id: r.redemption_id,
          couponCode: r.coupon_code,
          customerName: r.customer_name,
          amount: r.amount,
          status: r.status.titleize
        }
      }
    }
  end

  # GET /api/v1/merchant/redemptions/list
  def index
    redemptions = MerchantRedemption.where(merchant_id: params[:user_id])
                               .order(created_at: :desc)                                

    render json: {
      success: true,
      data: redemptions.map { |r|
        {
          redemption_id: r.redemption_id,
          couponCode: r.coupon_code,
          customerName: r.customer_name,
          amount: r.amount,
          redeemedAt: r.redeemed_at,
          status: r.status.titleize
        }
      }
    }
  end

  # GET /api/v1/merchant/redemptions/:redemption_id
  def show
    render json: {
      success: true,
      data: {
        redemption_id: @redemption.redemption_id,
        couponCode: @redemption.coupon_code,
        customerName: @redemption.customer_name,
        customerPhone: @redemption.customer_phone,
        amount: @redemption.amount,
        discountAmount: @redemption.discount_amount,
        finalAmount: @redemption.final_amount,
        redeemedAt: @redemption.redeemed_at&.strftime("%d %b %Y %I:%M %p"),
        status: @redemption.status.titleize
      }
    }
  end

  # PATCH /api/v1/merchant/redemptions/verify/:redemption_id
  def verify
    unless params[:status].present?
      return render json: {
        success: false,
        message: "Status is required"
      }, status: :unprocessable_entity
    end

    status = params[:status].downcase

    unless MerchantRedemption.statuses.key?(status)
      return render json: {
        success: false,
        message: "Invalid status"
      }, status: :unprocessable_entity
    end

    @redemption.update!(
      status: MerchantRedemption.statuses[status],
      redeemed_at: Time.current
    )

    render json: {
      success: true,
      message: "Redemption verified successfully",
      data: {
        redemption_id: @redemption.redemption_id,
        status: @redemption.status.titleize
      }
    }
  end

  # PATCH /api/v1/merchant/redemptions/reject/:redemption_id
  def reject
    unless params[:reason].present?
      return render json: {
        success: false,
        message: "Reject reason is required"
      }, status: :unprocessable_entity
    end

    @redemption.update!(
      status: :rejected,
      reject_reason: params[:reason]
    )

    render json: {
      success: true,
      message: "Redemption rejected successfully",
      data: {
        redemption_id: @redemption.redemption_id,
        status: @redemption.status.titleize
      }
    }
  end

  # GET /api/v1/merchant/redemptions/recent
  def recent
    redemptions = MerchantRedemption.where(merchant_id: params[:user_id])
                               .order(created_at: :desc)                

    render json: {
      success: true,
      data: redemptions.map { |r|
        {
          redemption_id: r.redemption_id,
          couponCode: r.coupon_code,
          customerName: r.customer_name,
          amount: r.amount
        }
      }
    }
  end

  # GET /api/v1/merchant/redemptions/pending
  def pending
    redemptions = MerchantRedemption.where(
        merchant_id: params[:user_id],
        status: MerchantRedemption.statuses[:pending]
      ).order(created_at: :desc)                

    render json: {
      success: true,
      data: redemptions.map { |r|
        {
          redemption_id: r.redemption_id,
          couponCode: r.coupon_code,
          customerName: r.customer_name,
          amount: r.amount,
          status: r.status.titleize
        }
      }
    }
  end

  private
  
    def set_redemption
      @redemption = MerchantRedemption.find_by(
        redemption_id: params[:redemption_id]
      )

      unless @redemption
        render json: {
          success: false,
          message: "Redemption not found"
        }, status: :not_found
      end
    end
end
