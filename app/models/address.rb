class Address < ApplicationRecord
  belongs_to :user

  validates :full_name, :phone, :address1, :city,
            :state, :pincode, :country, presence: true
end
