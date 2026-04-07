class Api::V1::RestaurantsController < ApplicationController
  before_action :set_restaurant, only: [ :update, :destroy]
  skip_before_action :authenticate_request, only: [ :update, :destroy, :index ,:create , :generate_qr]

  def index
    @restaurants = Restaurant.includes(:category).all
    render json: @restaurants.as_json(include: { category: { only: [:id, :name] } }, methods: [:image_urls])
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)
    if @restaurant.save
      render json: { message: "Restaurant created successfully", restaurant: @restaurant }, status: :created
    else
      render json: { errors: @restaurant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @restaurant.update(restaurant_params)
      render json: { message: "Restaurant updated successfully", restaurant: @restaurant }
    else
      render json: { errors: @restaurant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @restaurant.destroy
    render json: { message: "Restaurant deleted successfully" }
  end

  def generate_qr
    restaurant = Restaurant.find(params[:id])
    puts "------000000000000000000000000000000000000000000"
    puts restaurant.qr_code.to_s

    qr = RQRCode::QRCode.new(restaurant.qr_code.to_s)
    png = qr.as_png(size: 300)

    base64 = Base64.strict_encode64(png.to_s)

    render json: { qr_code: base64 }
  end





  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:id])
  end

  def restaurant_params
    params.require(:restaurant).permit(:name, :description, :address, :category_id, images: [])
  end
end
