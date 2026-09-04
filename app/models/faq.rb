class Faq < ApplicationRecord
   belongs_to :faq_category, optional: true

  has_many :faq_feedbacks, dependent: :destroy

  validates :question, presence: true
  validates :answer, presence: true
end
