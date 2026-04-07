# class Coupon < ApplicationRecord
# end
require "rqrcode"

class Coupon < ApplicationRecord
  belongs_to :rule, optional: true
  belongs_to :user, optional: true
  has_one_attached :qr_image

  before_create :generate_code_and_qr
  has_many :coupon_redemptions, dependent: :destroy

  def generate_code_and_qr
    self.code ||= SecureRandom.hex(4).upcase
    qr = RQRCode::QRCode.new("COUPON:#{self.code}")
    png = qr.as_png(size: 300)
    file = Tempfile.new(["coupon_qr", ".png"])
    IO.binwrite(file.path, png.to_s)
    self.qr_image.attach(io: File.open(file.path), filename: "#{self.code}.png")
    file.close
  end
end
