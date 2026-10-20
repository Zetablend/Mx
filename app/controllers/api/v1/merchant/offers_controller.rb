# app/controllers/api/v1/merchant/offers_controller.rb
class Api::V1::Merchant::OffersController < ApplicationController
  skip_before_action :authenticate_request

  before_action :set_merchant
  before_action :set_offer, only: [:show, :update, :destroy]

  def stats
    offers = MerchantOffer.where(merchant_id: @merchant.id)

    render json: {
      success: true,
      data: {
        totalCampaigns: offers.count,
        activeBanners: offers.where(status: "Active").count,
        flashDeals: offers.where(priority: "High").count,
        homepageFeatured: offers.where(category: "Featured").count
      }
    }
  end

  def index
    offers = MerchantOffer.where(merchant_id: @merchant.id)

    if params[:search].present?
      search = "%#{params[:search]}%"
      offers = offers.where(
        "title LIKE :search OR subtitle LIKE :search",
        search: search
      )
    end

    offers = offers.where(category: params[:category]) if params[:category].present?
    offers = offers.where(priority: params[:type]) if params[:type].present?

    if params[:location_id].present? &&
      MerchantOffer.column_names.include?("location_id")
      offers = offers.where(location_id: params[:location_id])
    end

    page = [params[:page].to_i, 1].max
    limit = params[:limit].present? ? params[:limit].to_i.clamp(1, 100) : 10

    total = offers.count
    offers = offers.order(created_at: :desc)
                  .offset((page - 1) * limit)
                  .limit(limit)

    render json: {
      success: true,
      data: offers,
      pagination: {
        page: page,
        limit: limit,
        total: total,
        total_pages: (total.to_f / limit).ceil
      }
    }
  end

  def featured
    offers = MerchantOffer.where(
      merchant_id: @merchant.id,
      category: "Featured"
    )

    render json: {
      success: true,
      data: offers
    }
  end

  def expiring_soon
    if MerchantOffer.column_names.include?("expiry_date")
      offers = MerchantOffer
        .where(merchant_id: @merchant.id)
        .where(expiry_date: Date.current..7.days.from_now.to_date)
        .order(expiry_date: :asc)
    else
      offers = MerchantOffer.none
    end

    render json: {
      success: true,
      data: offers
    }
  end

  def list
    offers = MerchantOffer.where(merchant_id: @merchant.id)

    render json: {
      success: true,
      data: offers
    }
  end

  def create
    offer = MerchantOffer.new(offer_params)
    offer.merchant_id = @merchant.id

    if offer.save
      render json: {
        success: true,
        message: "Offer created successfully",
        data: offer
      }, status: :created
    else
      render json: {
        success: false,
        errors: offer.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @offer.update(offer_params)
      render json: {
        success: true,
        message: "Offer updated successfully",
        data: @offer
      }
    else
      render json: {
        success: false,
        errors: @offer.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def show
    render json: {
      success: true,
      data: @offer
    }
  end

  def destroy
    @offer.destroy

    render json: {
      success: true,
      message: "Offer deleted successfully"
    }
  end

  def analytics
    data = MerchantOffer
      .where(
        merchant_id: @merchant.id,
        created_at: 6.months.ago.beginning_of_month..Time.current
      )
      .group("DATE_FORMAT(created_at,'%b')")
      .count

    result = data.map do |month, count|
      {
        month: month,
        clicks: count
      }
    end

    render json: {
      success: true,
      data: result
    }
  end

  def banners
    banners = MerchantOffer
      .where(merchant_id: @merchant.id)
      .where.not(banner_image: nil)

    render json: {
      success: true,
      data: banners.select(:id, :title, :banner_image)
    }
  end

  private

  def set_merchant
    @merchant = User.find_by(id: params[:merchant_id])

    unless @merchant
      render json: {
        success: false,
        message: "Merchant not found"
      }, status: :not_found
    end
  end

  def set_offer
    @offer = MerchantOffer.find_by(
      id: params[:id],
      merchant_id: @merchant.id
    )

    unless @offer
      render json: {
        success: false,
        message: "Offer not found"
      }, status: :not_found
    end
  end

  def offer_params
    params.permit(
      :title,
      :subtitle,
      :category,
      :priority,
      :status,
      :banner_image,
      :clicks
    )
  end
end
