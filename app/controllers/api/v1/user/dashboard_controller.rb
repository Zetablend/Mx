class Api::V1::User::DashboardController < ApplicationController
  skip_before_action :authenticate_request

  def stats
    user = ::User.find_by(id: params[:user_id])

    unless user
      return render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end

    render json: {
      success: true,
      data: {
        wallet: 1250,
        coupons: 8,
        redeemed: 3,
        referrals: 5
      }
    }
  end

  def wallet_stats
    user = ::User.find_by(id: params[:user_id])

    unless user
      return render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end

    data = 5.downto(0).map do |months_ago|
      date = months_ago.months.ago

      transactions = user.wallet_transactions.where(
        created_at: date.beginning_of_month..date.end_of_month
      )

      {
        month: date.strftime("%b"),
        earned: transactions.where(transaction_type: "earned").sum(:amount).to_f,
        redeemed: transactions.where(transaction_type: "redeemed").sum(:amount).to_f
      }
    end

    render json: {
      success: true,
      data: data
    }
  end

  def coupon_usage
    user = ::User.find_by(id: params[:user_id])

    unless user
      return render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end

    data = 5.downto(0).map do |months_ago|
      date = months_ago.months.ago

      coupon_count = CouponRedemption.where(
        user_id: user.id,
        redeemed_at: date.beginning_of_month..date.end_of_month
      ).count

      {
        month: date.strftime("%b"),
        value: coupon_count
      }
    end

    render json: {
      success: true,
      data: data
    }
  end
end
