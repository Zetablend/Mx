class Staff < ApplicationRecord
  validates :name, presence: true
  validates :role, presence: true
  validates :permission, presence: true
  validates :status, presence: true

  before_create :generate_staff_id

  private

  def generate_staff_id
    last_staff = Staff.order(:id).last

    if last_staff&.staff_id.present?
      last_number = last_staff.staff_id.gsub(/\D/, "").to_i
      self.staff_id = "STF#{last_number + 1}"
    else
      self.staff_id = "STF1001"
    end
  end
end
