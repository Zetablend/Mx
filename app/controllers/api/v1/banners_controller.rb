class Api::V1::BannersController < ApplicationController
  skip_before_action :authenticate_request, only: [:update, :destroy, :index, :create]
  before_action :set_banner, only: [:update, :destroy]

  # GET /api/v1/banners
  def index
    banners = Banner.all
    render json: banners.map { |b| banner_json(b) }
  end

  # POST /api/v1/banners
  def create
    banner = Banner.new(banner_params)

    # attach image only if a valid file is present
    if params[:image].present? && params[:image] != "null"
      banner.image.attach(params[:image])
    end

    if banner.save
      render json: banner_json(banner), status: :created
    else
      render json: { errors: banner.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/banners/:id
  def update
    # safely handle update without image re-attachment errors
    if @banner.update(filtered_banner_params)
      if params[:image].present? && params[:image] != "null"
        @banner.image.purge if @banner.image.attached?
        @banner.image.attach(params[:image])
      end

      render json: banner_json(@banner)
    else
      render json: { errors: @banner.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/banners/:id
  def destroy
    @banner.destroy
    head :no_content
  end

  private

  def set_banner
    @banner = Banner.find(params[:id])
  end

  # Regular banner params (for create)
  def banner_params
    params.permit(:title, :link, :device_type, :status, :image)
  end

  # Filtered params (for update)
  def filtered_banner_params
    permitted = params.permit(:title, :link, :device_type, :status)
    # handle boolean properly
    permitted[:status] = ActiveModel::Type::Boolean.new.cast(permitted[:status])
    permitted
  end

  def banner_json(banner)
    {
      id: banner.id,
      title: banner.title,
      link: banner.link,
      device_type: banner.device_type,
      status: banner.status,
      image_url: banner.image.attached? ? url_for(banner.image) : nil
    }
  end
end
