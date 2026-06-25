class Api::V1::AddressesController < ApplicationController
  skip_before_action :authenticate_request
  before_action :set_user
  before_action :set_address, only: [:update, :destroy, :default]

  # GET /api/v1/addresses?user_id=1
  def index
    render json: {
      success: true,
      addresses: @user.addresses.order(is_default: :desc)
    }
  end

  # POST /api/v1/addresses
  def create
    address = @user.addresses.new(address_params)

    if address.is_default
      @user.addresses.update_all(is_default: false)
    end

    if address.save
      render json: {
        success: true,
        message: "Address added successfully",
        address: address
      }, status: :created
    else
      render json: {
        success: false,
        errors: address.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/addresses/:id
  def update
    if ActiveModel::Type::Boolean.new.cast(address_params[:is_default])
      @user.addresses.where.not(id: @address.id).update_all(is_default: false)
    end

    if @address.update(address_params)
      render json: {
        success: true,
        message: "Address updated successfully",
        address: @address
      }
    else
      render json: {
        success: false,
        errors: @address.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/addresses/:id?user_id=1
  def destroy
    @address.destroy

    render json: {
      success: true,
      message: "Address deleted successfully"
    }
  end

  # PATCH /api/v1/addresses/:id/default?user_id=1
  def default
    @user.addresses.update_all(is_default: false)
    @address.update(is_default: true)

    render json: {
      success: true,
      message: "Default address updated successfully",
      address: @address
    }
  end

  private

  def set_user
    @user = User.find_by(id: params[:user_id])

    unless @user
      render json: {
        success: false,
        message: "User not found"
      }, status: :not_found and return
    end
  end

  def set_address
    @address = @user.addresses.find_by(id: params[:id])

    unless @address
      render json: {
        success: false,
        message: "Address not found"
      }, status: :not_found and return
    end
  end

  def address_params
    params.permit(
      :full_name,
      :phone,
      :address1,
      :address2,
      :city,
      :state,
      :pincode,
      :country,
      :address_type,
      :is_default
    )
  end
end
