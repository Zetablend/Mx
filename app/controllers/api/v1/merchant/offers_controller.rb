# app/controllers/api/v1/merchant/offers_controller.rb

class Api::V1::Merchant::OffersController < ApplicationController
  skip_before_action :authenticate_request
  before_action :set_offer, only: [:show, :update, :destroy]

  def stats
    render json: {
      success: true,
      data: {
        totalCampaigns: MerchantOffer.count,
        activeBanners: MerchantOffer.where(status: "Active").count,
        flashDeals: MerchantOffer.where(priority: "High").count,
        homepageFeatured: MerchantOffer.where(category: "Featured").count
      }
    }
  end

  def index
    offers = MerchantOffer.all

    offers = offers.where(
      "title LIKE ?", "%#{params[:search]}%"
    ) if params[:search].present?

    offers = offers.where(status: params[:status]) if params[:status].present?
    offers = offers.where(category: params[:category]) if params[:category].present?

    page = (params[:page] || 1).to_i
    limit = (params[:limit] || 10).to_i

    total = offers.count

    offers = offers.offset((page - 1) * limit).limit(limit)

    render json: {
      success: true,
      data: offers,
      pagination: {
        page: page,
        limit: limit,
        total: total
      }
    }
  end

  def list
    render json: {
      success: true,
      data: MerchantOffer.all
    }
  end

  def create
    offer = MerchantOffer.new(offer_params)

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
        message: "Offer updated successfully"
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
            .where(created_at: 6.months.ago.beginning_of_month..Time.current)
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
    banners = MerchantOffer.where.not(banner_image: nil)

    render json: {
      success: true,
      data: banners.select(:id, :title, :banner_image)
    }
  end

  private

  def set_offer
    @offer = MerchantOffer.find_by(id: params[:id])

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
      :merchant_id
    )
  end
end
