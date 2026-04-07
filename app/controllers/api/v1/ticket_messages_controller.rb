# class Api::V1::TicketMessagesController < ApplicationController
#   before_action :authenticate_request, only: [ :index ,:create]
# #   before_action :authenticate_request
#   before_action :set_ticket

#   def index
#     messages = @ticket.ticket_messages.includes(:user).order(:created_at)
#     render json: messages.as_json(
#       include: { user: { only: [:id, :name] } }
#     )
#   end

#   def create
#     message = @ticket.ticket_messages.new(
#       body: params[:body],
#       user: current_user
#     )

#     if message.save
#       render json: message, status: :created
#     else
#       render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
#     end
#   end

#   private

#   def set_ticket
#     @ticket = Ticket.find(params[:ticket_id])
#   end
# end
class Api::V1::TicketMessagesController < ApplicationController
  before_action :set_ticket

  def index
    messages = @ticket.ticket_messages.includes(:user).order(:created_at)
    render json: messages.as_json(include: { user: { only: [:id, :name] } })
  end

  def create
    message = @ticket.ticket_messages.new(
      body: params.dig(:ticket_message, :body),
      user: current_user
    )

    if message.save
      render json: message, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:ticket_id])
  end
end


