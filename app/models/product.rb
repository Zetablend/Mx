class Product < ApplicationRecord
    belongs_to :product_category
    has_one_attached :image
    validates :name, :price, :stock, presence: true
end
