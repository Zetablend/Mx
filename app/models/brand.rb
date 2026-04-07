class Brand < ApplicationRecord
    belongs_to :category
    has_one_attached :image

    validates :name, :category_id, presence: true
end
