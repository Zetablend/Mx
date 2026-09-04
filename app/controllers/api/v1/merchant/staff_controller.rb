class Api::V1::Merchant::StaffController < ApplicationController
  skip_before_action :authenticate_request

  # POST /api/v1/merchant/staff/create
  def create
    staff = Staff.new(staff_params)

    if staff.save
      render json: {
        success: true,
        message: "Staff addedsuccessfully",
        data: {
          staff_id: staff.staff_id,
          name: staff.name,
          role: staff.role
        }
      }, status: :created
    else
      render json: {
        success: false,
        message: "Failed to add staff",
        errors: staff.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/merchant/staff/list
  def list
    staffs = Staff.order(created_at: :desc)

    render json: {
      success: true,
      data: staffs.map do |staff|
        {
          name: staff.name,
          role: staff.role,
          permission: staff.permission,
          status: staff.status
        }
      end
    }, status: :ok
  end

  private

  def staff_params
    params.permit(
      :name,
      :role,
      :permission,
      :status
    )
  end
end
