class Api::V1::CategoriesController < ApplicationController
  skip_before_action :authenticate_request

  before_action :set_category, only: [:show, :update, :destroy]

  # GET /api/v1/categories?search=&location_id=&page=1&limit=12
  def index
    categories = Category.all

    # Search
    if params[:search].present?
      categories = categories.where(
        "LOWER(name) LIKE ?",
        "%#{params[:search].downcase}%"
      )
    end

    # Pagination
    page = params[:page].presence || 1
    limit = params[:limit].presence || 12

    page = page.to_i
    limit = limit.to_i

    page = 1 if page < 1
    limit = 12 if limit < 1

    total = categories.count

    categories = categories
      .offset((page - 1) * limit)
      .limit(limit)

    render json: {
      success: true,
      data: categories.map { |category| category_json(category) },
      pagination: {
        page: page,
        limit: limit,
        total: total
      }
    }
  end

  # GET /api/v1/categories/popular
  def popular
    categories = Category.where(is_popular: true)

    render json: {
      success: true,
      data: categories.map { |category| category_json(category, false) }
    }
  end

  # GET /api/v1/categories/:id
  def show
    render json: {
      success: true,
      data: category_json(@category, true)
    }
  end

  # POST /api/v1/categories
  def create
    category = Category.new(category_params)

    if category.save
      render json: category, status: :created
    else
      render json: {
        errors: category.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PUT/PATCH /api/v1/categories/:id
  def update
    if @category.update(category_params)
      render json: @category
    else
      render json: {
        errors: @category.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/categories/:id
  def destroy
    @category.destroy

    render json: {
      success: true,
      message: "Category deleted successfully"
    }, status: :ok
  end

  private

  def set_category
    @category = Category.find_by(id: params[:id])

    unless @category
      render json: {
        success: false,
        message: "Category not found"
      }, status: :not_found
    end
  end

  def category_json(category, include_description = false)
    data = {
      id: category.id,
      name: category.name,
      image: category.image,
      stats: {
        outlets_count: category.restaurants.count,
        coupons_count: 0
      },
      is_popular: category.is_popular
    }

    data[:description] = category.description if include_description

    data
  end

  def category_params
    params.require(:category).permit(
      :name,
      :image,
      :description,
      :is_popular
    )
  end
end

