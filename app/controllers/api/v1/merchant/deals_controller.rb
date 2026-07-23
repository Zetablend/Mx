class Api::V1::Merchant::DealsController < ApplicationController
  skip_before_action :authenticate_request
  before_action :set_deal, only: [:show, :update, :destroy]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  # GET /api/v1/merchant/deals
  def index
    deals = MerchantDeal.order(created_at: :desc)

    render json: {
      success: true,
      data: deals
    }, status: :ok
  end

  # GET /api/v1/merchant/deals/list
  def list
    page = params[:page].presence || 1
    limit = params[:limit].presence || 10

    deals = MerchantDeal.order(created_at: :desc)
                        .offset((page.to_i - 1) * limit.to_i)
                        .limit(limit.to_i)

    render json: {
      success: true,
      data: deals,
      pagination: {
        page: page.to_i,
        limit: limit.to_i,
        total_records: MerchantDeal.count
      }
    }
  end

  # GET /api/v1/merchant/deals/:deal_code
  def show
    render json: {
      success: true,
      data: @deal
    }
  end

  # POST /api/v1/merchant/deals
  def create
    deal = MerchantDeal.new(deal_params)

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

  # PUT /api/v1/merchant/deals/:deal_code
  def update
    @deal.banner_image.attach(params[:banner_image]) if params[:banner_image].present?

    if @deal.update(deal_params)
      render json: {
        success: true,
        message: "Deal updated successfully",
        data: @deal
      }
    else
      render json: {
        success: false,
        errors: @deal.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/merchant/deals/:deal_code
  def destroy
    @deal.destroy

    render json: {
      success: true,
      message: "Deal deleted successfully"
    }
  end

  # GET /api/v1/merchant/deals/filter
  def filter
    deals = MerchantDeal.all

    deals = deals.search(params[:search]) if params[:search].present?
    deals = deals.filter_status(params[:status]) if params[:status].present?
    deals = deals.filter_category(params[:category]) if params[:category].present?

    page = params[:page].to_i
    page = 1 if page <= 0

    limit = params[:limit].to_i
    limit = 10 if limit <= 0

    total_records = deals.count

    deals = deals.offset((page - 1) * limit).limit(limit)

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

  # GET /api/v1/merchant/deals/stats
  def stats
    render json: {
      success: true,
      data: {
        totalDeals: MerchantDeal.count,
        activeDeals: MerchantDeal.active.count,
        inactiveDeals: MerchantDeal.inactive.count,
        draftDeals: MerchantDeal.draft.count,
        expiredDeals: MerchantDeal.expired.count,
        totalRevenue: MerchantDeal.sum(:revenue),
        totalViews: MerchantDeal.sum(:views),
        totalClicks: MerchantDeal.sum(:clicks)
      }
    }, status: :ok
  end

  # GET /api/v1/merchant/deals/analytics
  def analytics
    deals = MerchantDeal.order(created_at: :asc)

    render json: {
      success: true,
      data: deals.map { |deal|
        {
          month: deal.created_at.strftime("%b"),
          views: deal.views,
          clicks: deal.clicks,
          revenue: deal.revenue
        }
      }
    }
  end

  # GET /api/v1/merchant/deals/dashboard
  def dashboard
    recent_deals = MerchantDeal.order(created_at: :desc).limit(5)

    render json: {
      success: true,
      data: {
        totalDeals: MerchantDeal.count,
        activeDeals: MerchantDeal.active.count,
        inactiveDeals: MerchantDeal.inactive.count,
        draftDeals: MerchantDeal.draft.count,
        expiredDeals: MerchantDeal.expired.count,
        totalRevenue: MerchantDeal.sum(:revenue),
        totalViews: MerchantDeal.sum(:views),
        totalClicks: MerchantDeal.sum(:clicks),
        recentDeals: recent_deals
      }
    }, status: :ok
  end

  private

  def set_deal
    @deal = MerchantDeal.find_by!(deal_code: params[:deal_code])
  end

  def deal_params
    params.require(:merchant_deal).permit(
      :merchant_id,
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
