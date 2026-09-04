class FaqFeedback < ApplicationRecord
  belongs_to :faq
  validates :helpful, inclusion: { in: [true, false] }
end
