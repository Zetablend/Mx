class Api::V1::OffersController < ApplicationController
    skip_before_action :authenticate_request, only: [ :update, :destroy, :index ,:create]
    before_action :set_offer, only: [:show, :update, :destroy]

  def index
    offers = Offer.includes(:category).all
    render json: offers.map { |o| offer_json(o) }
  end

  def show
    render json: offer_json(@offer)
  end

  def create
    offer = Offer.new(offer_params)
    offer.image.attach(params[:image]) if params[:image].present?

    if offer.save
      render json: offer_json(offer), status: :created
    else
      render json: { errors: offer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @offer.update(offer_params)
      @offer.image.attach(params[:image]) if params[:image].present?
      render json: offer_json(@offer)
    else
      render json: { errors: @offer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @offer.destroy
    head :no_content
  end

  private

  def set_offer
    @offer = Offer.find(params[:id])
  end

  def offer_params
    params.permit(:title, :description, :discount_type, :value, :category_id, :start_date, :end_date, :status)
  end

  def offer_json(o)
    {
      id: o.id,
      title: o.title,
      description: o.description,
      discount_type: o.discount_type,
      value: o.value,
      start_date: o.start_date,
      end_date: o.end_date,
      status: o.status,
      category: o.category&.name,
      image_url: o.image.attached? ? url_for(o.image) : nil
    }
  end
end
