class Api::V1::FaqCategoriesController < ApplicationController
  skip_before_action :authenticate_request

  # POST /api/v1/faq_categories
  def create
    category = FaqCategory.new(faq_category_params)

    if category.save
      render json: {
        success: true,
        message: "FAQ category created successfully",
        data: {
          id: category.id,
          name: category.name
        }
      }, status: :created
    else
      render json: {
        success: false,
        message: category.errors.full_messages.join(", ")
      }, status: :unprocessable_entity
    end
  end

  private

  def faq_category_params
    params.require(:faq_category).permit(:name)
  end
end
