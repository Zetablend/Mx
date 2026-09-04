class Api::V1::Merchant::DealsController < ApplicationController
  skip_before_action :authenticate_request
  before_action :set_deal, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  # GET /api/v1/merchant/deals?merchant_id=15
  def index
    deals = merchant_deals.order(created_at: :desc)

    render json: {
      success: true,
      data: deals
    }, status: :ok
  end

  # GET /api/v1/merchant/deals/list?merchant_id=15&page=1&limit=10
  def list
    page = params[:page].presence || 1
    limit = params[:limit].presence || 10

    deals = merchant_deals
              .order(created_at: :desc)
              .offset((page.to_i - 1) * limit.to_i)
              .limit(limit.to_i)

    render json: {
      success: true,
      data: deals,
      pagination: {
        page: page.to_i,
        limit: limit.to_i,
        total_records: merchant_deals.count
      }
    }, status: :ok
  end

  # GET /api/v1/merchant/deals/:deal_code?merchant_id=15
  def show
    render json: {
      success: true,
      data: @deal
    }, status: :ok
  end

  # POST /api/v1/merchant/deals?merchant_id=15
  def create
    deal = MerchantDeal.new(deal_params)
    deal.merchant_id = params[:merchant_id]

    deal.banner_image.attach(params[:banner_image]) if params[:banner_image].present?

    if deal.save
      render json: {
        success: true,
        message: "Deal created successfully",
        data: deal
      }, status: :created
    else
      render json: {
        success: false,
        errors: deal.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/merchant/deals/:deal_code?merchant_id=15
  def update
    @deal.banner_image.attach(params[:banner_image]) if params[:banner_image].present?

    if @deal.update(deal_params)
      render json: {
        success: true,
        message: "Deal updated successfully",
        data: @deal
      }, status: :ok
    else
      render json: {
        success: false,
        errors: @deal.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/merchant/deals/:deal_code?merchant_id=15
  def destroy
    @deal.destroy

    render json: {
      success: true,
      message: "Deal deleted successfully"
    }, status: :ok
  end

  # GET /api/v1/merchant/deals/filter?merchant_id=15
  def filter
    deals = merchant_deals

    deals = deals.search(params[:search]) if params[:search].present?
    deals = deals.filter_status(params[:status]) if params[:status].present?
    deals = deals.filter_category(params[:category]) if params[:category].present?

    page = params[:page].to_i
    page = 1 if page <= 0

    limit = params[:limit].to_i
    limit = 10 if limit <= 0

    total_records = deals.count

    deals = deals
              .order(created_at: :desc)
              .offset((page - 1) * limit)
              .limit(limit)

    render json: {
      success: true,
      data: deals,
      pagination: {
        page: page,
        limit: limit,
        total_records: total_records
      }
    }, status: :ok
  end

  # GET /api/v1/merchant/deals/stats?merchant_id=15
  def stats
    deals = merchant_deals

    render json: {
      success: true,
      data: {
        totalDeals: deals.count,
        activeDeals: deals.active.count,
        inactiveDeals: deals.inactive.count,
        draftDeals: deals.draft.count,
        expiredDeals: deals.expired.count,
        totalRevenue: deals.sum(:revenue),
        totalViews: deals.sum(:views),
        totalClicks: deals.sum(:clicks)
      }
    }, status: :ok
  end

  # GET /api/v1/merchant/deals/analytics?merchant_id=15
  def analytics
    deals = merchant_deals.order(created_at: :asc)

    render json: {
      success: true,
      data: deals.map do |deal|
        {
          month: deal.created_at.strftime("%b"),
          views: deal.views,
          clicks: deal.clicks,
          revenue: deal.revenue
        }
      end
    }, status: :ok
  end

  # GET /api/v1/merchant/deals/dashboard?merchant_id=15
  def dashboard
    deals = merchant_deals

    recent_deals = deals.order(created_at: :desc).limit(5)

    render json: {
      success: true,
      data: {
        totalDeals: deals.count,
        activeDeals: deals.active.count,
        inactiveDeals: deals.inactive.count,
        draftDeals: deals.draft.count,
        expiredDeals: deals.expired.count,
        totalRevenue: deals.sum(:revenue),
        totalViews: deals.sum(:views),
        totalClicks: deals.sum(:clicks),
        recentDeals: recent_deals
      }
    }, status: :ok
  end

  private

  # All deals belonging to requested merchant
  def merchant_deals
    merchant_id = params[:merchant_id]

    if merchant_id.blank?
      raise ActionController::ParameterMissing, "merchant_id is required"
    end

    MerchantDeal.where(merchant_id: merchant_id)
  end

  def set_deal
    merchant_id = params[:merchant_id]

    if merchant_id.blank?
      raise ActionController::ParameterMissing, "merchant_id is required"
    end

    @deal = MerchantDeal.find_by!(
      deal_code: params[:deal_code],
      merchant_id: merchant_id
    )
  end

  def deal_params
    params.require(:merchant_deal).permit(
      :title,
      :description,
      :category,
      :discount_type,
      :discount_value,
      :start_date,
      :end_date,
      :status
    )
  end

  def record_not_found
    render json: {
      success: false,
      message: "Deal not found."
    }, status: :not_found
  end

  def parameter_missing(exception)
    render json: {
      success: false,
      message: exception.message
    }, status: :bad_request
  end
end
