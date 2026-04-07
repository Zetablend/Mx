class Api::V1::ProductCategoriesController < ApplicationController
    skip_before_action :authenticate_request, only: [:index ,:create, :update ,:destroy ]
    def index
        render json: ProductCategory.all
    end

    def create
        category = ProductCategory.new(category_params)
        if category.save
        render json: category
        else
        render json: { errors: category.errors.full_messages }, status: 422
        end
    end

    def update
    category = ProductCategory.find(params[:id])

    if category.update(category_params)
      render json: category
    else
      render json: { errors: category.errors.full_messages }, status: 422
    end
  end

  def destroy
    category = ProductCategory.find(params[:id])

    if category.destroy
      render json: { message: "Category deleted successfully" }
    else
      render json: { errors: category.errors.full_messages }, status: 422
    end
  end



    private
    def category_params
        params.require(:product_category).permit(:name)
    end
end
