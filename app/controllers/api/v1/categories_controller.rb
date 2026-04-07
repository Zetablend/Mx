class Api::V1::CategoriesController < ApplicationController
    skip_before_action :authenticate_request, only: [:update, :destroy, :index ,:create]
    before_action :set_category, only: [ :update, :destroy]

      def index
        categories = Category.includes(:subcategories)
        render json: categories.to_json(include: :subcategories)
      end

      def create
        category = Category.new(category_params)
        if category.save
          render json: category, status: :created
        else
          render json: { errors: category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @category.update(category_params)
          render json: @category
        else
          render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @category.destroy
        head :no_content
      end

      private

      def set_category
        @category = Category.find(params[:id])
      end

      def category_params
        params.require(:category).permit(:name)
      end
end