class MerchantReview < ApplicationRecord
  belongs_to :merchant, class_name: "User"

  enum :status, {
    pending: 0,
    published: 1
  }

  before_create :generate_review_id

  scope :merchant_reviews, ->(merchant) { where(merchant: merchant) }

  private

  def generate_review_id
    self.review_id ||= "REV#{SecureRandom.random_number(9999).to_s.rjust(4, '0')}"
  end
end
