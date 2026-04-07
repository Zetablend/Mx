class Category < ApplicationRecord
    has_many :subcategories, dependent: :destroy
    validates :name, presence: true, uniqueness: true
    has_many :restaurants, dependent: :destroy
end
