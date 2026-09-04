module Api
  module V1
    class LocationsController < ApplicationController
      skip_before_action :authenticate_request

      before_action :set_location, only: [:show]

      # GET /api/v1/locations
      def index
        user = ::User.find_by(id: params[:user_id])

        unless user
          return render json: {
            success: false,
            message: "User not found"
          }, status: :not_found
        end

        merchant_locations = MerchantLocation.where(merchant_id: user.id)

        # Optional state filter
        if params[:state].present?
          merchant_locations = merchant_locations.where(
            "LOWER(state) = ?",
            params[:state].downcase
          )
        end

        locations = merchant_locations
          .where.not(city: [nil, ""])
          .group(:city, :state)
          .count

        data = locations.map do |(city, state), outlet_count|
          {
            city: city,
            state: state,
            country: "India",
            outlets: outlet_count
          }
        end

        render json: {
          success: true,
          data: data
        }
      end

      # GET /api/v1/locations/states
      def states
        user = ::User.find_by(id: params[:user_id])

        unless user
          return render json: {
            success: false,
            message: "User not found"
          }, status: :not_found
        end

        states = Location
                  .where(user_id: user.id)
                  .where.not(state: [nil, ""])
                  .distinct
                  .order(:state)
                  .pluck(:state)

        render json: {
          success: true,
          data: states
        }
      end

      # GET /api/v1/locations/:id
      def show
        render json: {
          success: true,
          data: location_json(@location, true)
        }
      end

      private

      def set_location
        user = ::User.find_by(id: params[:user_id])

        unless user
          render json: {
            success: false,
            message: "User not found"
          }, status: :not_found
          return
        end

        @location = Location.find_by(
          id: params[:id],
          user_id: user.id
        )

        unless @location
          render json: {
            success: false,
            message: "Location not found"
          }, status: :not_found
        end
      end

      def location_json(location, include_description = false)
        data = {
          id: location.id,
          name: location.name,
          state: location.state,
          country: location.country,
          image: location.image,
          outlets_count: 0,
          services: [],
          is_popular: location.is_popular
        }

        if include_description
          data[:description] = location.description
        end

        data
      end
    end
  end
end
