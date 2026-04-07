# class Api::V1::RulesController < ApplicationController
#     skip_before_action :authenticate_request, only: [ :update, :destroy, :index ,:create]
#     before_action :set_rule, only: [:show, :update, :destroy]

#   def index
#     @rules = Rule.all
#     render json: @rules
#   end

#   def show
#     render json: @rule
#   end

#   def create
#     @rule = Rule.new(rule_params)
#     if @rule.save
#       render json: @rule, status: :created
#     else
#       render json: { errors: @rule.errors.full_messages }, status: :unprocessable_entity
#     end
#   end

#   def update
#     if @rule.update(rule_params)
#       render json: @rule
#     else
#       render json: { errors: @rule.errors.full_messages }, status: :unprocessable_entity
#     end
#   end

#   def destroy
#     @rule.destroy
#     head :no_content
#   end

#   private

#   def set_rule
#     @rule = Rule.find(params[:id])
#   end

#   def rule_params
#     params.require(:rule).permit(
#       :name,
#       :loyalty_program_type,
#       :trigger_event,
#       :stamp_type,
#       :stamp_expiration,
#       :target_audience,
#       :event_types,
#       :summary,
#       voucher_rules: {},
#       notification_rules: {},
#       point_redemption: {},
#       conditions: {}
#     )
#   end
# end


class Api::V1::RulesController < ApplicationController
  skip_before_action :authenticate_request, only: [ :update, :destroy, :index ,:create]
  before_action :set_rule, only: [:update, :destroy]


  def index
    render json: Rule.all
  end

  def show
    render json: @rule
  end

  def create
    @rule = Rule.new(rule_params)
    if @rule.save
      render json: @rule, status: :created
    else
      render json: { errors: @rule.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @rule.update(rule_params)
      render json: @rule
    else
      render json: { errors: @rule.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @rule.destroy
    head :no_content
  end

  private

  def rule_params
    params.require(:rule).permit(
      :name,
      :loyalty_program_type,
      :trigger_event,
      :stamp_type,
      :stamp_expiration,
      :target_audience,
      :event_types,
      :summary,
      voucher_rules: [
        :name, :description, :discount_type, :value,
        :min_points_required, :applicable_on, :max_usage_per_user, :expiration_date
      ]
    )
  end
end
