class Product < ApplicationRecord
    belongs_to :product_category
    has_one_attached :image
    validates :name, :price, :stock, presence: true
    has_many :wishlists, dependent: :destroy
end
