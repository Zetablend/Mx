class Api::V1::ReferralPlansController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :create, :update, :destroy]

  def index
    plans = ReferralPlan.all
    render json: plans
  end

  def create
    plan = ReferralPlan.new(referral_plan_params)
    if plan.save
      render json: plan, status: :created
    else
      render json: { errors: plan.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    plan = ReferralPlan.find(params[:id])
    if plan.update(referral_plan_params)
      render json: plan
    else
      render json: { errors: plan.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    plan = ReferralPlan.find(params[:id])
    plan.destroy
    head :no_content
  end

  private

  def referral_plan_params
    params.require(:referral_plan).permit(:name, :description, :reward_type, :reward_value, :expiration_date, :status)
  end
end
