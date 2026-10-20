class Campaign < ApplicationRecord
  belongs_to :category
  belongs_to :location
  belongs_to :restaurant, optional: true
end
