class FaqCategory < ApplicationRecord
  
  has_many :faqs, dependent: :nullify

  validates :name, presence: true
end
