class Api::V1::QrController < ApplicationController
  def scan
    code = params[:code]
    coupon = Coupon.find_by(code: code)
    if coupon.present?
      if coupon.status == "active"
        coupon.update(status: "redeemed")
        render json: { message: "✅ Coupon Redeemed Successfully!", coupon: coupon }
      else
        render json: { message: "⚠️ Coupon already used or expired." }, status: 400
      end
    else
      render json: { message: "❌ Invalid QR Code" }, status: 404
    end
  end
end
