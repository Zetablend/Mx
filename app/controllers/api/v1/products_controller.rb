class Api::V1::ProductsController < ApplicationController
    skip_before_action :authenticate_request, only: [:index ,:create, :update, :destroy]

    include Rails.application.routes.url_helpers
    def index
    products = Product.all

    render json: products.map { |p|
        {
        id: p.id,
        name: p.name,
        price: p.price,
        stock: p.stock,
        description: p.description,
        category: p.product_category&.name,
        category_id: p.product_category_id,

        # ⭐ IMAGE URL RETURN HERE
        image_url: p.image.attached? ? url_for(p.image) : nil
        }
    }
    end
    
    def create
        product = Product.new(product_params)
        product.image.attach(params[:image]) if params[:image]

        if product.save
        render json: product
        else
        render json: { errors: product.errors.full_messages }, status: 422
        end
    end

    def update
        product = Product.find(params[:id])

        product.assign_attributes(product_params)
        product.image.attach(params[:image]) if params[:image]

        if product.save
        render json: product
        else
        render json: { errors: product.errors.full_messages }, status: 422
        end
    end

    def destroy
        product = Product.find(params[:id])

        if product.destroy
        render json: { message: "Product deleted successfully" }
        else
        render json: { errors: product.errors.full_messages }, status: 422
        end
    end



    private
    def product_params
        params.require(:product).permit(:name, :price, :stock, :description, :product_category_id)
    end
end
