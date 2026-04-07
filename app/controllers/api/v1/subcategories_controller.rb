class Api::V1::SubcategoriesController < ApplicationController
    skip_before_action :authenticate_request, only: [ :update, :destroy, :index ,:create]
    before_action :set_subcategory, only: [:update, :destroy]

    def index
    subcategories = Subcategory.includes(:category)
    render json: subcategories.to_json(include: :category)
    end

    def create
    subcategory = Subcategory.new(subcategory_params)
    if subcategory.save
        render json: subcategory, status: :created
    else
        render json: { errors: subcategory.errors.full_messages }, status: :unprocessable_entity
    end
    end

    def update
    if @subcategory.update(subcategory_params)
        render json: @subcategory
    else
        render json: { errors: @subcategory.errors.full_messages }, status: :unprocessable_entity
    end
    end

    def destroy
    @subcategory.destroy
    head :no_content
    end

    private

    def set_subcategory
    @subcategory = Subcategory.find(params[:id])
    end

    def subcategory_params
    params.require(:subcategory).permit(:name, :category_id)
    end
end


