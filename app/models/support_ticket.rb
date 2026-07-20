class SupportTicket < ApplicationRecord
  belongs_to :merchant, class_name: "User"

  STATUSES = ["Open", "In Progress", "Closed"]

  validates :subject, presence: true
  validates :status,
            inclusion: {
              in: STATUSES,
              message: "%{value} is not valid"
            }
end
