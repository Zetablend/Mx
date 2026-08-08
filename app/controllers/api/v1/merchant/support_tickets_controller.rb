module Api
  module V1
    module Merchant
      class SupportTicketsController < ApplicationController
        skip_before_action :authenticate_request
        before_action :set_user
        before_action :set_ticket, only: [:show, :update, :destroy]

        def index
          user = ::User.find_by(id: params[:user_id])

          return render json: {
            success: false,
            message: "User not found"
          }, status: :not_found unless user

          tickets = user.support_tickets.order(created_at: :desc)

          tickets = tickets.where(
            "subject ILIKE :search OR ticket_number ILIKE :search",
            search: "%#{params[:search]}%"
          ) if params[:search].present?

          tickets = tickets.where(status: params[:status]) if params[:status].present?
          tickets = tickets.where(ticket_type: params[:ticket_type]) if params[:ticket_type].present?
          tickets = tickets.where(priority: params[:priority]) if params[:priority].present?

          # Pagination
          page = params[:page].present? ? params[:page].to_i : 1
          limit = params[:limit].present? ? params[:limit].to_i : 10

          total_records = tickets.count

          tickets = tickets.offset((page - 1) * limit).limit(limit)

          render json: {
            success: true,
            data: tickets.map { |ticket| ticket_response(ticket) },
            pagination: {
              current_page: page,
              per_page: limit,
              total_records: total_records,
              total_pages: (total_records.to_f / limit).ceil
            }
          }, status: :ok
        end

        def show
          user = ::User.find_by(id: params[:user_id])

          return render json: {
            success: false,
            message: "User not found"
          }, status: :not_found unless user

          ticket = user.support_tickets.find_by(id: params[:id])

          return render json: {
            success: false,
            message: "Ticket not found"
          }, status: :not_found unless ticket

          render json: {
            success: true,
            data: ticket_response(ticket)
          }
        end

        def create
          user = ::User.find_by(id: params[:user_id])

          return render json: {
            success: false,
            message: "User not found"
          }, status: :not_found unless user

          ticket = user.support_tickets.new(ticket_params)

          ticket.status = "Open"
          ticket.assigned_to = "Application Support"

          if ticket.save
            render json: {
              success: true,
              message: "Support ticket created successfully.",
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
          user = ::User.find_by(id: params[:user_id])

          return render json: {
            success: false,
            message: "User not found"
          }, status: :not_found unless user

          ticket = user.support_tickets.find_by(id: params[:id])

          return render json: {
            success: false,
            message: "Ticket not found"
          }, status: :not_found unless ticket

          if ticket.update(ticket_params)
            render json: {
              success: true,
              message: "Ticket updated successfully.",
              data: ticket_response(ticket)
            }
          else
            render json: {
              success: false,
              errors: ticket.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        def destroy
          user = ::User.find_by(id: params[:user_id])

          return render json: {
            success: false,
            message: "User not found"
          }, status: :not_found unless user

          ticket = user.support_tickets.find_by(id: params[:id])

          return render json: {
            success: false,
            message: "Ticket not found"
          }, status: :not_found unless ticket

          ticket.destroy

          render json: {
            success: true,
            message: "Ticket deleted successfully."
          }
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
          params.permit(
            :subject,
            :description,
            :priority,
            :ticket_type
          )
        end

        def ticket_response(ticket)
          {
            ticket_id: ticket.id,
            merchant_id: ticket.merchant_id,
            ticket_number: ticket.ticket_number,
            subject: ticket.subject,
            description: ticket.description,
            priority: ticket.priority,
            ticket_type: ticket.ticket_type,
            assigned_to: ticket.assigned_to,
            status: ticket.status,
            created_at: ticket.created_at,
            updated_at: ticket.updated_at
          }
        end
      end
    end
  end
end
