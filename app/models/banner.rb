class Banner < ApplicationRecord
  has_one_attached :image

  validates :title, :device_type, presence: true
  validates :device_type, inclusion: { in: %w[small large] }

end
