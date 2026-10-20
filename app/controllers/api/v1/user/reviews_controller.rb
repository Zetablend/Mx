class Api::V1::User::ReviewsController < ApplicationController
  skip_before_action :authenticate_request
  
  before_action :set_review, only: [:update, :destroy]

  def index
    user = User.find_by(id: params[:user_id])

    unless user
      return render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end

    reviews = Review.includes(:restaurant)
                    .where(user_id: user.id)
                    .order(created_at: :desc)

    reviews = reviews.where(rating: params[:rating]) if params[:rating].present?

    if params[:restaurant_id].present?
      reviews = reviews.where(restaurant_id: params[:restaurant_id])
    end

    reviews = reviews.order(created_at: :asc) if params[:sort] == "oldest"

    render json: {
      success: true,
      data: reviews.map do |review|
        {
          id: review.id,
          restaurant: {
            id: review.restaurant&.id,
            name: review.restaurant&.name
          },
          location: {
            id: nil,
            name: review.restaurant&.address
          },
          rating: review.rating,
          comment: review.comment,
          date: review.created_at.strftime("%Y-%m-%d"),
          status: review.visible? ? "Approved" : "Pending",
          image: nil
        }
      end
    }, status: :ok
  end

  def create
    user = User.find_by(id: params[:user_id])

    unless user
      return render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end

    review = Review.new(review_params)
    review.user = user

    if review.save
      render json: {
        success: true,
        message: "Review submitted successfully",
        data: {
          id: review.id,
          user_id: review.user_id,
          restaurant_id: review.restaurant_id,
          rating: review.rating,
          comment: review.comment
        }
      }, status: :created
    else
      render json: {
        success: false,
        errors: review.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @review.update(review_params)
      render json: {
        success: true,
        message: "Review updated successfully",
        data: {
          id: @review.id,
          rating: @review.rating,
          comment: @review.comment
        }
      }, status: :ok
    else
      render json: {
        success: false,
        errors: @review.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @review.destroy

    render json: {
      success: true,
      message: "Review deleted successfully"
    }, status: :ok
  end

  def stats
    user = User.find_by(id: params[:user_id])

    unless user
      return render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end

    reviews = Review.where(user_id: user.id)

    positive_reviews = reviews.where("rating >= ?", 4).count
    pending_reviews = reviews.where(visible: false).count

    top_restaurant_id = reviews.group(:restaurant_id)
                               .count
                               .max_by { |_, count| count }
                               &.first

    top_restaurant = Restaurant.find_by(id: top_restaurant_id)

    render json: {
      success: true,
      data: {
        total_reviews: reviews.count,
        positive_reviews: positive_reviews,
        pending_reviews: pending_reviews,
        average_rating: reviews.average(:rating)&.round(1) || 0,
        top_restaurant: top_restaurant&.name
      }
    }, status: :ok
  end

  private

  def set_review
    user = User.find_by(id: params[:user_id])

    unless user
      return render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end

    @review = Review.find_by(
      id: params[:id],
      user_id: user.id
    )

    unless @review
      return render json: {
        success: false,
        message: "Review not found"
      }, status: :not_found
    end
  end

  def review_params
    params.permit(:restaurant_id, :rating, :comment)
  end
end
