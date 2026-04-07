class Api::V1::CouponsController < ApplicationController
  skip_before_action :authenticate_request, only: [ :destroy, :index ,:create ,:show, :create_from_event , :redeem ]
  before_action :set_coupon, only: [:show, :redeem, :destroy]

  def index
    coupons = Coupon.includes(:rule).all
    render json: coupons.map { |c| coupon_json(c) }
  end

  def show
    render json: coupon_json(@coupon)
  end

  def create
    rule = Rule.find(params[:rule_id])
    rule.voucher_rules.each do |voucher|
      coupon = Coupon.create!(
        rule_id: rule.id,
        name: voucher["name"],
        description: voucher["description"],
        discount_type: voucher["discount_type"],
        value: voucher["value"],
        applicable_on: voucher["applicable_on"],
        max_usage_per_user: voucher["max_usage_per_user"],
        expiration_date: voucher["expiration_date"],
        status: "active"
      )
    end
    render json: { message: "Coupons created for this rule" }
  end


  def create_from_event
    event = params[:event] # example: "user_signup"
    user_id = params[:user_id]

    # find matching rules
    rules = Rule.where(trigger_event: event)

    if rules.empty?
      return render json: { message: "No rules found for this event." }, status: 404
    end

    created_coupons = []

    rules.each do |rule|
      rule.voucher_rules.each do |voucher|
        coupon = Coupon.create!(
          rule_id: rule.id,
          user_id: user_id,
          name: voucher["name"],
          description: voucher["description"],
          discount_type: voucher["discount_type"],
          value: voucher["value"],
          applicable_on: voucher["applicable_on"],
          max_usage_per_user: voucher["max_usage_per_user"],
          expiration_date: voucher["expiration_date"],
          status: "active"
        )
        created_coupons << coupon
      end
    end

    render json: { message: "Coupons created successfully!", coupons: created_coupons.map { |c| { id: c.id, code: c.code, name: c.name } } }, status: :created
  end

  def redeem
    user_id = params[:user_id] || @coupon.user_id

    puts "-----------------------"
    puts user_id.to_s
    puts "-----------------------"
    @coupon.update(status: "redeemed")
    puts "Redeeming coupon with params: #{params.inspect}"
    puts @coupon.inspect.to_s

    CouponRedemption.create!(
      coupon_id: @coupon.id,
      user_id: user_id,
      redeemed_at: Time.current,
      location: params[:location],
      remarks: params[:remarks]
    )

    render json: { message: "Coupon redeemed successfully!", coupon_id: @coupon.id }
  end

  # def generate_qr
  #   coupon = Coupon.find(params[:id])
  #   qr_text = "coupon://#{coupon.code}"

  #   qrcode = RQRCode::QRCode.new(qr_text)

  #   png = qrcode.as_png(size: 300)
  #   filename = "coupon_qr_#{coupon.id}.png"
  #   filepath = Rails.root.join("public", "qr_codes", filename)

  #   FileUtils.mkdir_p(Rails.root.join("public", "qr_codes"))
  #   IO.binwrite(filepath, png.to_s)

  #   render json: { qr_code_url: "/qr_codes/#{filename}" }
  # end



  def destroy
    @coupon.destroy
    head :no_content
  end

  private

  def set_coupon
    @coupon = Coupon.find(params[:id])
  end

  def coupon_json(c)
    {
      id: c.id,
      code: c.code,
      name: c.name,
      description: c.description,
      discount_type: c.discount_type,
      value: c.value,
      status: c.status,
      expiration_date: c.expiration_date,
      rule_name: c.rule&.name,
      image_url: c.qr_image.attached? ? url_for(c.qr_image) : nil
    }
  end
end
