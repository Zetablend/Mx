# app/controllers/api/v1/faqs_controller.rb
# class Api::V1::FaqsController < ApplicationController
 
#   before_action :authenticate_request!, only: [ :index , :create ]
  

#   def index
#     render json: Faq.where(active: true)
#   end

#   def create
#     faq = Faq.create!(faq_params)
#     render json: faq
#   end

#   private

#   def faq_params
#     params.require(:faq).permit(:question, :answer, :active)
#   end

#   def admin_only
#     render json: { error: "Unauthorized" }, status: :unauthorized unless current_user.admin?
#   end
# end
# class Api::V1::FaqsController < ApplicationController
# #   before_action :authenticate_request!

#  skip_before_action :authenticate_request, only: [ :index ,:create , :destroy] 



# #   before_action :admin_only, only: [:create]

#   def index
#     render json: Faq.where(active: true)
#   end

#   def create
#     faq = Faq.create!(faq_params)
#     render json: faq
#   end

#   def destroy
#     faq = Faq.find(params[:id])
#     faq.destroy
#     render json: { message: "FAQ deleted successfully" }
#   end

#   private

#   def faq_params
#     params.require(:faq).permit(:question, :answer, :active)
#   end

# #   def admin_only
# #     render json: { error: "Unauthorized" }, status: :unauthorized unless current_user.role == "admin"
# #   end
# end
class Api::V1::FaqsController < ApplicationController
  skip_before_action :authenticate_request

  # GET /api/v1/faqs/categories
  def categories
    categories = FaqCategory.order(:id)

    render json: {
      success: true,
      data: categories.map do |category|
        {
          id: category.id,
          name: category.name
        }
      end
    }
  end

  # GET /api/v1/faqs
  def index
    faqs = Faq.includes(:faq_category)

    if params[:category_id].present?
      faqs = faqs.where(faq_category_id: params[:category_id])
    end

    if params[:search].present?
      search = "%#{params[:search]}%"

      faqs = faqs.where(
        "question ILIKE :search OR answer ILIKE :search",
        search: search
      )
    end

    page = params[:page].to_i
    page = 1 if page <= 0

    limit = params[:limit].to_i
    limit = 10 if limit <= 0

    total = faqs.count

    faqs = faqs
             .order(id: :asc)
             .offset((page - 1) * limit)
             .limit(limit)

    render json: {
      success: true,
      data: faqs.map do |faq|
        {
          id: faq.id,
          question: faq.question,
          answer: faq.answer,
          category: {
            id: faq.faq_category.id,
            name: faq.faq_category.name
          },
          is_popular: faq.is_popular
        }
      end,
      pagination: {
        page: page,
        limit: limit,
        total: total
      }
    }
  end

  def create
    faq = Faq.new(faq_params)

    if faq.save
      render json: {
        success: true,
        message: "FAQ created successfully",
        data: faq_response(faq)
      }, status: :created
    else
      render json: {
        success: false,
        message: faq.errors.full_messages.join(", ")
      }, status: :unprocessable_entity
    end
  end


  # GET /api/v1/faqs/popular
  def popular
    faqs = Faq.where(is_popular: true).order(id: :asc)

    render json: {
      success: true,
      data: faqs.map do |faq|
        {
          id: faq.id,
          question: faq.question
        }
      end
    }
  end

  # POST /api/v1/faqs/:id/feedback
  def feedback
    faq = Faq.find_by(id: params[:id])

    unless faq
      return render json: {
        success: false,
        message: "FAQ not found"
      }, status: :not_found
    end

    helpful = params[:helpful]

    if helpful.nil?
      return render json: {
        success: false,
        message: "helpful is required"
      }, status: :unprocessable_entity
    end

    helpful =
      if helpful == true || helpful == "true"
        true
      elsif helpful == false || helpful == "false"
        false
      else
        return render json: {
          success: false,
          message: "helpful must be true or false"
        }, status: :unprocessable_entity
      end

    faq.faq_feedbacks.create!(helpful: helpful)

    render json: {
      success: true,
      message: "Feedback recorded"
    }
  end

  private

  def faq_params
    params.require(:faq).permit(
      :question,
      :answer,
      :faq_category_id,
      :is_popular
    )
  end

  def faq_response(faq)
    {
      id: faq.id,
      question: faq.question,
      answer: faq.answer,
      category: {
        id: faq.faq_category.id,
        name: faq.faq_category.name
      },
      is_popular: faq.is_popular
    }
  end
end
