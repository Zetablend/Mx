module Api
  module V1
    module Merchant
      class SupportTicketsController < ApplicationController
        skip_before_action :authenticate_request
        before_action :set_user
        before_action :set_ticket, only: [:show, :update, :destroy]

        def index
          tickets = @user.support_tickets.order(created_at: :desc)

          if tickets.present?
            render json: {
              success: true,
              data: tickets.map { |ticket| ticket_response(ticket) }
            }, status: :ok
          else
            render json: {
              success: false,
              message: "Tickets not found"
            }, status: :not_found
          end
        end

        def show
          render json: {
            success: true,
            data: ticket_response(@ticket)
          }, status: :ok
        end

        def create
          ticket = @user.support_tickets.new(ticket_params)

          if ticket.save
            render json: {
              success: true,
              message: "Ticket created successfully",
              data: ticket_response(ticket)
            }, status: :created
          else
            render json: {
              success: false,
              errors: ticket.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        def update
          if @ticket.update(ticket_params)
            render json: {
              success: true,
              message: "Ticket updated successfully",
              data: ticket_response(@ticket)
            }, status: :ok
          else
            render json: {
              success: false,
              errors: @ticket.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        def destroy
          @ticket.destroy

          render json: {
            success: true,
            message: "Ticket deleted successfully"
          }, status: :ok
        end

        private

        def set_user
          @user = ::User.find_by(id: params[:user_id])

          unless @user
            render json: {
              success: false,
              message: "User not found"
            }, status: :not_found
          end
        end

        def set_ticket
          @ticket = @user.support_tickets.find_by(id: params[:id])

          unless @ticket
            render json: {
              success: false,
              message: "Ticket not found"
            }, status: :not_found
          end
        end

        def ticket_params
          params.permit(:subject, :status)
        end

        def ticket_response(ticket)
          {
            ticket_id: "##{ticket.id}",
            subject: ticket.subject,
            status: ticket.status,
            created_at: ticket.created_at
          }
        end
      end
    end
  end
end
