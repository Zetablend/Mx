class SubscriptionPlan < ApplicationRecord
    validates :name, :price, :duration_days, presence: true
    validates :price, numericality: { greater_than_or_equal_to: 0 }

    # For feature list
    # serialize :features, JSON
end
