class Api::V1::PaymentOptionsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :create, :update, :destroy]

  def index
    options = PaymentOption.all
    render json: options.map { |o| option_json(o) }
  end

  def create
    option = PaymentOption.new(payment_option_params)
    option.status = "Active"
    if option.save
      render json: option_json(option), status: :created
    else
      render json: { errors: option.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    option = PaymentOption.find(params[:id])
    if option.update(payment_option_params)
      render json: option_json(option)
    else
      render json: { errors: option.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    option = PaymentOption.find(params[:id])
    option.destroy
    head :no_content
  end

  private

  def payment_option_params
    params.permit(:name, :provider, :account_details, :status, :qr_image)
  end

  def option_json(o)
    {
      id: o.id,
      name: o.name,
      provider: o.provider,
      account_details: o.account_details,
      status: o.status,
      qr_image_url: o.qr_image.attached? ? url_for(o.qr_image) : nil
    }
  end
end
