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
class Api::V1::FaqsController < ApplicationController
#   before_action :authenticate_request!

 skip_before_action :authenticate_request, only: [ :index ,:create , :destroy] 



#   before_action :admin_only, only: [:create]

  def index
    render json: Faq.where(active: true)
  end

  def create
    faq = Faq.create!(faq_params)
    render json: faq
  end

  def destroy
    faq = Faq.find(params[:id])
    faq.destroy
    render json: { message: "FAQ deleted successfully" }
  end

  private

  def faq_params
    params.require(:faq).permit(:question, :answer, :active)
  end

#   def admin_only
#     render json: { error: "Unauthorized" }, status: :unauthorized unless current_user.role == "admin"
#   end
end
