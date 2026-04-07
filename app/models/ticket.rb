class Ticket < ApplicationRecord
  belongs_to :user

  STATUSES = ["Open", "In Progress", "Closed"]
  has_many :ticket_messages, dependent: :destroy

  validates :subject, :message, presence: true
  # validates :status, inclusion: { in: STATUSES }

  before_create { self.status ||= "Open" }
end
