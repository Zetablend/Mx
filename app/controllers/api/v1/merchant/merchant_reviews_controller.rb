class Api::V1::Merchant::MerchantReviewsController < ApplicationController
  skip_before_action :authenticate_request
  before_action :set_user
  before_action :set_review, only: [:show, :reply, :report]

  def stats
    reviews = MerchantReview.where(merchant: @user)

    render json: {
      success: true,
      data: {
        totalReviews: reviews.count,
        averageRating: reviews.average(:rating).to_f.round(1),
        positiveReviews: reviews.where("rating >= 4").count,
        negativeReviews: reviews.where("rating <= 2").count
      }
    }
  end

  def create
    review = MerchantReview.new(review_params)
    review.merchant = @user

    if review.save
      render json: {
        success: true,
        message: "Review created successfully",
        data: {
          review_id: review.review_id,
          customerName: review.customer_name,
          customerEmail: review.customer_email,
          rating: review.rating,
          comment: review.comment,
          reviewDate: review.review_date,
          status: review.status.titleize
        }
      }, status: :created
    else
      render json: {
        success: false,
        errors: review.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def list
    reviews = MerchantReview.where(merchant: @user)

    render json: {
      success: true,
      data: reviews.map { |review|
        {
          review_id: review.review_id,
          customerName: review.customer_name,
          rating: review.rating,
          comment: review.comment,
          reviewDate: review.review_date,
          status: review.status.titleize
        }
      }
    }
  end

  def show
    render json: {
      success: true,
      data: {
        review_id: @review.review_id,
        customerName: @review.customer_name,
        customerEmail: @review.customer_email,
        rating: @review.rating,
        comment: @review.comment,
        reviewDate: @review.review_date,
        status: @review.status.titleize
      }
    }
  end

  def reply
    @review.update(reply: params[:reply])

    render json: {
      success: true,
      message: "Reply added successfully",
      data: {
        review_id: @review.review_id,
        reply: @review.reply
      }
    }
  end

  def report
    if @review.reported?
      render json: {
        success: false,
        message: "Review already reported"
      }, status: :unprocessable_entity
      return
    end

    @review.update(
      reported: true,
      report_reason: params[:reason],
      report_note: params[:note]
    )

    render json: {
      success: true,
      message: "Review reported successfully",
      data: {
        review_id: @review.review_id,
        status: "Reported",
        reason: @review.report_reason
      }
    }
  end

  def analytics
    reviews = MerchantReview.where(merchant: @user)

    monthly_reviews = reviews
      .group_by { |review| review.created_at.strftime("%b") }
      .map do |month, records|
        {
          month: month,
          reviews: records.count
        }
      end

    render json: {
      success: true,
      data: {
        monthlyReviews: monthly_reviews
      }
    }
  end

  private

  def set_user
    @user = User.find_by(id: params[:user_id])

    return if @user.present?

    render json: {
      success: false,
      message: "User not found"
    }, status: :not_found
  end

  def set_review
    @review = MerchantReview.find_by(
      review_id: params[:review_id],
      merchant: @user
    )

    return if @review.present?

    render json: {
      success: false,
      message: "Review not found"
    }, status: :not_found
  end

  def review_params
    params.permit(
      :customer_name,
      :customer_email,
      :rating,
      :comment,
      :review_date,
      :status
    )
  end
end
