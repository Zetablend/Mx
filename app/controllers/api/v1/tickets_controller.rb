# # app/controllers/api/v1/tickets_controller.rb
# class Api::V1::TicketsController < ApplicationController
#   skip_before_action :authenticate_request, only: [ :update, :index ,:create]
  

#   def index
#     render json: current_user.tickets.order(created_at: :desc)
#   end

#   def create
#     ticket = current_user.tickets.new(ticket_params)

#     if ticket.save
#       render json: ticket, status: :created
#     else
#       render json: { errors: ticket.errors.full_messages }, status: 422
#     end
#   end

#   def update
#     ticket = Ticket.find(params[:id])

#     if ticket.update(ticket_params)
#       render json: ticket
#     else
#       render json: { errors: ticket.errors.full_messages }, status: 422
#     end
#   end

#   private

#   def ticket_params
#     params.require(:ticket).permit(:subject, :message, :status)
#   end
# end
# app/controllers/api/v1/tickets_controller.rb
class Api::V1::TicketsController < ApplicationController
  # skip_before_action :authenticate_request!
  skip_before_action :authenticate_request, only: [ :update, :index ,:create]

  def index
    current_user = User.find(1)
    render json: current_user.tickets.order(created_at: :desc)
  end

  def create
    current_user = User.find(1)

    ticket = current_user.tickets.new(ticket_params)

    if ticket.save
      render json: ticket, status: :created
    else
      render json: { errors: ticket.errors.full_messages }, status: 422
    end
  end

  def update
    current_user = User.find(1)

    ticket = current_user.tickets.find(params[:id])

    if ticket.update(ticket_params)
      render json: ticket
    else
      render json: { errors: ticket.errors.full_messages }, status: 422
    end
  end

  private


  def ticket_params
    params.require(:ticket).permit(:subject, :message, :status)
  end
end
