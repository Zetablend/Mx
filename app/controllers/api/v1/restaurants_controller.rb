class Api::V1::RestaurantsController < ApplicationController
  before_action :set_restaurant, only: [ :show, :update, :destroy]
  skip_before_action :authenticate_request

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

  def popular
    restaurants = Restaurant.where(is_popular: true)

    render json: {
      success: true,
      data: restaurants.map do |restaurant|
        {
          id: restaurant.id,
          name: restaurant.name,
          image: restaurant.image_urls,
          rating: {
            average: restaurant.respond_to?(:rating) ? restaurant.rating : 0,
            count: 0
          }
        }
      end
    }
  end

  def show
    render json: {
      success: true,
      data: {
        id: @restaurant.id,
        name: @restaurant.name,
        image: @restaurant.image_urls,

        location: {
          id: nil,
          name: @restaurant.address
        },

        category: {
          id: @restaurant.category_id,
          name: @restaurant.category&.name
        },

        rating: {
          average: 0,
          count: 0
        },

        offers_count: Coupon.where(restaurant_id: @restaurant.id).count,
        description: @restaurant.description,
        is_popular: @restaurant.is_popular
      }
    }
  end

  def coupons
    restaurant = Restaurant.find(params[:id])
    coupons = Coupon.where(restaurant_id: restaurant.id)

    render json: {
      success: true,
      data: coupons.map do |coupon|
        {
          id: coupon.id,
          title: coupon.name,
          description: coupon.description,
          expiry_date: coupon.expiration_date&.strftime("%Y-%m-%d")
        }
      end
    }
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
