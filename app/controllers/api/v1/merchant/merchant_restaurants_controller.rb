class Api::V1::Merchant::MerchantRestaurantsController < ApplicationController
  skip_before_action :authenticate_request
  before_action :set_restaurant, only: [:show, :update, :destroy]

  # GET /api/v1/merchant/merchant_restaurants
  def index
    restaurants = MerchantRestaurant.order(created_at: :desc)

    page = params[:page].to_i
    page = 1 if page <= 0

    limit = params[:limit].to_i
    limit = 10 if limit <= 0

    restaurants = restaurants.offset((page - 1) * limit).limit(limit)

    render json: {
      success: true,
      restaurants: restaurants,
      pagination: {
        page: page,
        limit: limit,
        total: MerchantRestaurant.count
      }
    }
  end

  # GET /api/v1/merchant/merchant_restaurants/list
  def list
    restaurants = MerchantRestaurant.select(
      :restaurant_id,
      :restaurant_name,
      :category,
      :city,
      :status,
      :rating,
      :total_orders
    )

    render json: {
      success: true,
      restaurants: restaurants
    }
  end

  # GET /api/v1/merchant/merchant_restaurants/:restaurant_id
  def show
    render json: {
      success: true,
      restaurant: @restaurant
    }
  end

  # POST /api/v1/merchant/merchant_restaurants
  def create
    restaurant = MerchantRestaurant.new(restaurant_params)

    if restaurant.save
      render json: {
        success: true,
        message: "Restaurant created successfully.",
        restaurant: restaurant
      }, status: :created
    else
      render json: {
        success: false,
        errors: restaurant.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/merchant/merchant_restaurants/:restaurant_id
  def update
    if @restaurant.update(restaurant_params)
      render json: {
        success: true,
        message: "Restaurant updated successfully.",
        restaurant: @restaurant
      }
    else
      render json: {
        success: false,
        errors: @restaurant.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/merchant/merchant_restaurants/:restaurant_id
  def destroy
    @restaurant.destroy

    render json: {
      success: true,
      message: "Restaurant deleted successfully."
    }
  end

    # GET /api/v1/merchant/merchant_restaurants/stats
  def stats
    restaurants = MerchantRestaurant.all

    render json: {
      success: true,
      data: {
        total_restaurants: restaurants.count,
        active_restaurants: restaurants.active.count,
        inactive_restaurants: restaurants.inactive.count,
        total_orders: restaurants.sum(:total_orders),
        monthly_revenue: restaurants.sum(:monthly_revenue),
        average_rating: restaurants.average(:rating).to_f.round(2)
      }
    }
  end


  # GET /api/v1/merchant/merchant_restaurants/filter
  def filter
    restaurants = MerchantRestaurant.all

    restaurants = restaurants.search(params[:search]) if params[:search].present?

    restaurants = restaurants.filter_status(params[:status]) if params[:status].present?

    restaurants = restaurants.filter_city(params[:city]) if params[:city].present?

    page = params[:page].to_i
    page = 1 if page <= 0

    limit = params[:limit].to_i
    limit = 10 if limit <= 0

    total = restaurants.count

    restaurants = restaurants.offset((page - 1) * limit).limit(limit)

    render json: {
      success: true,
      restaurants: restaurants,
      pagination: {
        page: page,
        limit: limit,
        total_records: total
      }
    }
  end


  # GET /api/v1/merchant/merchant_restaurants/analytics
  def analytics
    monthly_orders = MerchantRestaurant
                      .group("DATE_FORMAT(created_at, '%b %Y')")
                      .order("MIN(created_at)")
                      .sum(:total_orders)

    monthly_revenue = MerchantRestaurant
                        .group("DATE_FORMAT(created_at, '%b %Y')")
                        .order("MIN(created_at)")
                        .sum(:monthly_revenue)

    render json: {
      success: true,
      data: {
        monthly_orders: monthly_orders.map do |month, orders|
          {
            month: month,
            orders: orders
          }
        end,
        monthly_revenue: monthly_revenue.map do |month, revenue|
          {
            month: month,
            revenue: revenue
          }
        end
      }
    }
  end


  # GET /api/v1/merchant/merchant_restaurants/dashboard
  def dashboard

    recent = MerchantRestaurant.order(created_at: :desc).limit(5)

    render json: {
      success: true,
      dashboard: {
        total_restaurants: MerchantRestaurant.count,
        active_restaurants: MerchantRestaurant.active.count,
        inactive_restaurants: MerchantRestaurant.inactive.count,
        recent_restaurants: recent
      }
    }
  end


  # GET /api/v1/merchant/merchant_restaurants/:restaurant_id/gallery
  def gallery

    restaurant = MerchantRestaurant.find_by(restaurant_id: params[:restaurant_id])

    if restaurant.nil?
      render json: {
        success: false,
        message: "Restaurant not found."
      }, status: :not_found
      return
    end

    render json: {
      success: true,
      restaurant_id: restaurant.restaurant_id,
      images: []
    }
  end


  # PATCH /api/v1/merchant/merchant_restaurants/:restaurant_id/settings
  def settings

    restaurant = MerchantRestaurant.find_by(restaurant_id: params[:restaurant_id])

    if restaurant.nil?
      render json: {
        success: false,
        message: "Restaurant not found."
      }, status: :not_found
      return
    end

    if restaurant.update(
      status: params[:status],
      notifications: params[:notifications],
      auto_accept_orders: params[:auto_accept_orders]
    )

      render json: {
        success: true,
        message: "Restaurant settings updated successfully.",
        restaurant: restaurant
      }

    else

      render json: {
        success: false,
        errors: restaurant.errors.full_messages
      }, status: :unprocessable_entity

    end
  end

  private

  def set_restaurant
    @restaurant = MerchantRestaurant.find_by(restaurant_id: params[:restaurant_id])

    unless @restaurant
      render json: {
        success: false,
        message: "Restaurant not found."
      }, status: :not_found
    end
  end

  def restaurant_params
    params.require(:merchant_restaurant).permit(
      :merchant_id,
      :restaurant_name,
      :description,
      :category,
      :phone,
      :email,
      :address,
      :city,
      :state,
      :zip_code,
      :status,
      :rating,
      :total_orders,
      :monthly_revenue,
      :notifications,
      :auto_accept_orders
    )
  end
end
