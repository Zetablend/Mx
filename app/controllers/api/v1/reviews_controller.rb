class Api::V1::ReviewsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :update, :destroy , :toggle_visibility]

  before_action :set_review, only: [:update, :destroy, :toggle_visibility]

  # GET /reviews
  def index
    reviews = Review.includes(:user, :restaurant).order(created_at: :desc)
    
    render json: reviews.map { |r|
      {
        id: r.id,
        rating: r.rating,
        comment: r.comment,
        visible: r.visible,
        user: r.user ? { id: r.user.id, name: r.user.name } : nil,
        restaurant: r.restaurant ? { id: r.restaurant.id, name: r.restaurant.name } : nil,
        created_at: r.created_at.strftime("%Y-%m-%d %H:%M")
      }
    }
  end

  # PUT /reviews/:id
  def update
    if @review.update(review_params)
      render json: { message: "Review updated successfully", review: @review }
    else
      render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /reviews/:id/toggle_visibility
  def toggle_visibility
    @review.update(visible: !@review.visible)
    render json: { message: "Review visibility updated", visible: @review.visible }
  end

  # DELETE /reviews/:id
  def destroy
    @review.destroy
    render json: { message: "Review deleted" }
  end

  private

  def set_review
    @review = Review.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
