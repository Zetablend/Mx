class Subcategory < ApplicationRecord
  # belongs_to :category

  belongs_to :category
  validates :name, presence: true
end
