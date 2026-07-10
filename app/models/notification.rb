class Notification < ApplicationRecord
  belongs_to :user
  validates :title, :message, :notification_type, presence: true
  scope :unread, -> { where(is_read: false) }
  scope :read, -> { where(is_read: true) }
end
