class Api::V1::SubscriptionPlansController < ApplicationController
    skip_before_action :authenticate_request, only: [ :update, :destroy, :index ,:create]
    before_action :set_plan, only: [:show, :update, :destroy]

  def index
    plans = SubscriptionPlan.all
    render json: plans
  end

  def show
    render json: @plan
  end

  def create
    plan = SubscriptionPlan.new(plan_params)
    if plan.save
      render json: plan, status: :created
    else
      render json: { errors: plan.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @plan.update(plan_params)
      render json: @plan
    else
      render json: { errors: @plan.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @plan.destroy
    head :no_content
  end

  private

  def set_plan
    @plan = SubscriptionPlan.find(params[:id])
  end

  def plan_params
    params.require(:subscription_plan).permit(:name, :description, :price, :duration_days, :status, features: [])
  end
end
