class Rule < ApplicationRecord
    has_many :coupons
    validates :name, :trigger_event, presence: true

end
