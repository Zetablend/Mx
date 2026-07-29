class Api::V1::Merchant::CustomersController < ApplicationController
  skip_before_action :authenticate_request
  before_action :set_customer, only: [:show, :activity]

  # GET /api/v1/merchant/customers/stats
  def stats
    customers = User.where(role: :merchant)

    render json: {
      success: true,
      data: {
        totalCustomers: customers.count,
        activeCustomers: customers.where(blocked: false).count,
        newCustomers: customers.where(created_at: Date.current.beginning_of_month..Time.current).count,
        blockedCustomers: customers.where(blocked: true).count
      }
    }
  end

  # GET /api/v1/merchant/customers/filter
  def filter
    customers = User.where(role: :merchant)

    if params[:search].present?
      customers = customers.where(
        "name LIKE :search OR email LIKE :search OR phone LIKE :search",
        search: "%#{params[:search]}%"
      )
    end

    if params[:status].present?
      case params[:status].downcase
      when "active"
        customers = customers.where(blocked: false)
      when "blocked"
        customers = customers.where(blocked: true)
      end
    end

    page = params[:page].presence.to_i
    page = 1 if page <= 0

    limit = params[:limit].presence.to_i
    limit = 10 if limit <= 0

    customers = customers.offset((page - 1) * limit).limit(limit)

    render json: {
      success: true,
      data: customers.map do |customer|
        {
          customer_id: "CUS#{customer.id}",
          name: customer.name,
          email: customer.email,
          phone: customer.phone,
          status: customer.blocked ? "Blocked" : "Active"
        }
      end
    }
  end

  # GET /api/v1/merchant/customers/list
  def list
    customers = User.where(role: :merchant)

    page = params[:page].to_i
    page = 1 if page <= 0

    limit = params[:limit].to_i
    limit = 10 if limit <= 0

    customers = customers.offset((page - 1) * limit).limit(limit)

    render json: {
      success: true,
      data: customers.map do |customer|
        {
          customer_id: "CUS#{customer.id}",
          name: customer.name,
          email: customer.email,
          phone: customer.phone,
          city: customer.location,
          totalOrders: 0,
          status: customer.blocked ? "Blocked" : "Active"
        }
      end
    }
  end

  # GET /api/v1/merchant/customers/:customer_id
  def show
    render json: {
      success: true,
      data: {
        customer_id: "CUS#{@customer.id}",
        name: @customer.name,
        email: @customer.email,
        phone: @customer.phone,
        city: @customer.location,
        joinedDate: @customer.created_at.to_date,
        totalOrders: 0,
        totalSpent: 0,
        status: @customer.blocked ? "Blocked" : "Active"
      }
    }
  end

    # GET /api/v1/merchant/customers/activity/:customer_id
    def activity
      render json: {
        success: true,
        data: [
          {
            activity_id: "ACT1001",
            type: "Login",
            description: "#{@customer.name} logged in",
            date: @customer.updated_at.to_date
          }
        ]
      }
    end

  # GET /api/v1/merchant/customers/analytics
  def analytics
    monthly_data = User.where(role: :merchant)
                      .group("MONTH(created_at)")
                      .count

    months = %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]

    data = monthly_data.map do |month, count|
      {
        month: months[month - 1],
        customers: count
      }
    end

    render json: {
      success: true,
      data: {
        monthlyCustomers: data
      }
    }
  end

  private

  def set_customer
    id = params[:customer_id].to_s.gsub("CUS", "")

    @customer = User.find_by(id: id, role: :merchant)

    unless @customer
      render json: {
        success: false,
        message: "Merchant not found"
      }, status: :not_found
    end
  end
end
