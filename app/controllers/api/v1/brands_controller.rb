class Api::V1::BrandsController < ApplicationController
    skip_before_action :authenticate_request, only: [:update, :destroy, :index, :create]
    before_action :set_brand, only: [:show, :update, :destroy]

  def index
    brands = Brand.includes(:category).all
    render json: brands.map { |b| brand_json(b) }
  end

  def show
    render json: brand_json(@brand)
  end

  def create
    brand = Brand.new(brand_params)
    brand.image.attach(params[:image]) if params[:image].present?

    if brand.save
      render json: brand_json(brand), status: :created
    else
      render json: { errors: brand.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @brand.update(brand_params)
      @brand.image.attach(params[:image]) if params[:image].present?
      render json: brand_json(@brand)
    else
      render json: { errors: @brand.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @brand.destroy
    head :no_content
  end

  private

  def set_brand
    @brand = Brand.find(params[:id])
  end

  def brand_params
    params.permit(:name, :description, :category_id)
  end

  def brand_json(brand)
    {
      id: brand.id,
      name: brand.name,
      description: brand.description,
      category: brand.category&.name,
      image_url: brand.image.attached? ? url_for(brand.image) : nil
    }
  end
end
