class Review < ApplicationRecord
  belongs_to :user
  belongs_to :restaurant

  scope :visible, -> { where(visible: true) }
  
end
