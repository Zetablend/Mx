class Api::V1::CampaignsController < ApplicationController
    skip_before_action :authenticate_request

    def index
      campaigns = Campaign.includes(:category, :location, :restaurant)

      if params[:search].present?
        search = "%#{ActiveRecord::Base.sanitize_sql_like(params[:search])}%"

        campaigns = campaigns.where(
          "campaigns.title LIKE :search OR campaigns.subtitle LIKE :search",
          search: search
        )
      end

      if params[:location_id].present?
        campaigns = campaigns.where(location_id: params[:location_id])
      end

      if params[:category].present?
        category = Category.find_by(id: params[:category]) ||
                  Category.find_by(name: params[:category])

        campaigns = category ? campaigns.where(category_id: category.id) :
                              campaigns.none
      end

      page = [params[:page].to_i, 1].max
      limit = params[:limit].present? ? params[:limit].to_i : 10
      limit = [[limit, 1].max, 100].min

      total = campaigns.count
      campaigns = campaigns.order(created_at: :desc)
                          .offset((page - 1) * limit)
                          .limit(limit)

      render json: {
        success: true,
        data: campaigns.map { |campaign| campaign_json(campaign) },
        pagination: {
          page: page,
          limit: limit,
          total: total,
          total_pages: (total.to_f / limit).ceil
        }
      }
    end

    def show
      campaign = Campaign.includes(:category, :location, :restaurant)
      .find_by(id: params[:id])

      
      unless campaign
        return render json: {
          success: false,
          message: "Campaign not found"
        }, status: :not_found
      end

      render json: {
        success: true,
        data: campaign_json(campaign, details: true)
      }

    end

    private

    def campaign_json(campaign, details: false)
      restaurant = campaign.restaurant

      data = {
        id: campaign.id,
        title: campaign.title,
        subtitle: campaign.subtitle,
        restaurant: {
          id: restaurant&.id || 0,
          name: restaurant&.name || "Multiple Restaurants"
        },
        category: {
          id: campaign.category.id,
          name: campaign.category.name
        },
        type: campaign.campaign_type,
        discount: {
          type: campaign.discount_type,
          value: campaign.discount_value,
          label: campaign.discount_type == "percentage" ?
            "#{campaign.discount_value.to_i}% OFF" :
            "#{campaign.discount_value} OFF"
        },
        location: {
          id: campaign.location.id,
          name: campaign.location.name
        },
        usage: {
          used: campaign.usage_used || 0,
          limit: campaign.usage_limit
        },
        start_date: campaign.start_date,
        end_date: campaign.end_date,
        audience: campaign.audience,
        image: campaign.image,
        terms: campaign.terms || []
      }

      data[:description] = campaign.description if details
      data

    end
end
