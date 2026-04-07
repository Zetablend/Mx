class Offer < ApplicationRecord
    belongs_to :category
    has_one_attached :image

    validates :title, :discount_type, :value, :category_id, presence: true
    validates :discount_type, inclusion: { in: %w[Percentage Flat] }

    def active?
        status && (start_date.nil? || start_date <= Date.today) && (end_date.nil? || end_date >= Date.today)
    end
end
