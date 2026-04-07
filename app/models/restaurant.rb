class Restaurant < ApplicationRecord
  belongs_to :category
  has_many_attached :images
  before_create :generate_qr_code
  validates :name, :description, :address, :category_id, presence: true
  has_many :reviews, dependent: :destroy


  def image_urls
    return [] unless images.attached?

    images.map do |image|
      Rails.application.routes.url_helpers.url_for(image)
    end
  end

  private

  def generate_qr_code
    self.qr_code = "RES#{SecureRandom.hex(3).upcase}"
  end

end

