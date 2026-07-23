# app/controllers/api/v1/merchant/reviews_controller.rb

class Api::V1::Merchant::ReviewsController < ApplicationController
  def index
    merchant = current_user

    return render json: {
      success: false,
      message: "User not found"
    }, status: :unauthorized unless merchant

    reviews =
      Review
        .includes(:user)
        .where(visible: true)
        .order(created_at: :desc)
        .limit(10)

    if reviews.blank?
      return render json: {
        success: false,
        message: "Reviews unavailable"
      }, status: :ok
    end

    data =
      reviews.map do |review|
        {
          user: review.user&.name || "N/A",
          rating: review.rating,
          comment: review.comment
        }
      end

    render json: {
      success: true,
      data: data
    }, status: :ok
  end
end