class Api::V1::Merchant::MerchantLocationsController < ApplicationController
  skip_before_action :authenticate_request
  before_action :set_location, only: [:show, :update, :staff]

  # GET /api/v1/merchant/locations/stats
  def stats
    locations = MerchantLocation.all

    render json: {
      success: true,
      data: {
        totalLocations: locations.count,
        activeLocations: locations.active.count,
        inactiveLocations: locations.inactive.count,
        totalStaff: locations.sum(:total_staff)
      }
    }, status: :ok
  end

  # GET /api/v1/merchant/locations/filter
  def filter
    locations = MerchantLocation.all

    locations = locations.search(params[:search]) if params[:search].present?
    locations = locations.filter_status(params[:status]) if params[:status].present?

    page = params[:page].to_i
    page = 1 if page <= 0

    limit = params[:limit].to_i
    limit = 10 if limit <= 0

    locations = locations.offset((page - 1) * limit).limit(limit)

    render json: {
      success: true,
      data: locations.as_json(
        only: [
          :location_id,
          :location_name,
          :city,
          :status
        ]
      )
    }
  end

  # GET /api/v1/merchant/locations/list
  def list
    locations = MerchantLocation.all.order(created_at: :desc)

    render json: {
      success: true,
      data: locations.as_json(
        only: [
          :location_id,
          :location_name,
          :city,
          :manager,
          :status
        ]
      )
    }
  end

  # POST /api/v1/merchant/locations/create
  def create
    location = MerchantLocation.new(location_params)

    if location.save
      render json: {
        success: true,
        message: "Location created successfully",
        data: location
      }, status: :created
    else
      render json: {
        success: false,
        errors: location.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/merchant/locations/update/:location_id
  def update
    if @location.update(location_params)
      render json: {
        success: true,
        message: "Location updated successfully",
        data: @location
      }, status: :ok
    else
      render json: {
        success: false,
        errors: @location.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/merchant/locations/:location_id
  def show
    render json: {
      success: true,
      data: @location
    }, status: :ok
  end

  # GET /api/v1/merchant/locations/staff/:location_id
  def staff
    render json: {
      success: true,
      data: {
        location_id: @location.location_id,
        location_name: @location.location_name,
        manager: @location.manager,
        phone: @location.phone,
        total_staff: @location.total_staff
      }
    }, status: :ok
  end

  # GET /api/v1/merchant/locations/analytics
  def analytics
    locations = MerchantLocation.all

    city_wise = locations.group(:city).count

    active = locations.active.count
    inactive = locations.inactive.count

    render json: {
      success: true,
      data: {
        total_locations: locations.count,
        active_locations: active,
        inactive_locations: inactive,
        total_staff: locations.sum(:total_staff),
        city_wise_locations: city_wise
      }
    }, status: :ok
  end

  # GET /api/v1/merchant/locations/dashboard
  def dashboard
    merchant = User.find_by(id: params[:merchant_id])

    return render json: {
      success: false,
      message: "Merchant not found"
    }, status: :not_found unless merchant

    locations = MerchantLocation.where(merchant_id: merchant.id)

    render json: {
      success: true,
      data: {
        merchant_name: merchant.try(:full_name) || merchant.try(:name),
        total_locations: locations.count,
        active_locations: locations.active.count,
        inactive_locations: locations.inactive.count,
        total_staff: locations.sum(:total_staff)
      }
    }, status: :ok
  end

  private

  def set_location
    @location = MerchantLocation.find_by(location_id: params[:location_id])

    return if @location.present?

    render json: {
      success: false,
      message: "Location not found"
    }, status: :not_found
  end

  def location_params
    params.permit(
      :merchant_id,
      :location_name,
      :address,
      :city,
      :state,
      :zip_code,
      :manager,
      :phone,
      :status,
      :total_staff
    )
  end
end
