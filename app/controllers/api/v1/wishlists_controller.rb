class Api::V1::WishlistsController < ApplicationController
  skip_before_action :authenticate_request

  def toggle
    user = User.find_by(id: params[:user_id])
    product = Product.find_by(id: params[:product_id])

    unless user
      return render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end

    unless product
      return render json: {
        success: false,
        message: "Product not found"
      }, status: :not_found
    end

    wishlist = Wishlist.find_by(
      user_id: user.id,
      product_id: product.id
    )

    if wishlist
      wishlist.destroy

      render json: {
        success: true,
        message: "Product removed from wishlist",
        wishlisted: false
      }
    else
      Wishlist.create!(
        user_id: user.id,
        product_id: product.id
      )

      render json: {
        success: true,
        message: "Product added to wishlist",
        wishlisted: true
      }
    end
  end
end
