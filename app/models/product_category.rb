class ProductCategory < ApplicationRecord
    has_many :products, dependent: :destroy
    validates :name, presence: true
end
