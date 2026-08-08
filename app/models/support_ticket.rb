class SupportTicket < ApplicationRecord
  belongs_to :merchant, class_name: "User"
  before_validation :generate_ticket_number, on: :create

  STATUSES = ["Open", "Pending", "Resolved", "Closed"]

  PRIORITIES = ["Low", "Medium", "High"]

  TYPES = [
    "Customer Issue",
    "Fraud Report",
    "Technical",
    "Billing"
  ]
  validates :priority, inclusion: { in: PRIORITIES }

  validates :ticket_type, inclusion: { in: TYPES }

  validates :description, presence: true
  validates :priority, presence: true
  validates :ticket_type, presence: true
  validates :ticket_number, uniqueness: true

  validates :subject, presence: true
  validates :status,
            inclusion: {
              in: STATUSES,
              message: "%{value} is not valid"
            }

  private

  def generate_ticket_number
    self.ticket_number = "SUP-#{Time.current.year}-#{SecureRandom.random_number(100000).to_s.rjust(5, '0')}"
  end
end
