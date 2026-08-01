class MerchantNotification < ApplicationRecord
  belongs_to :merchant, class_name: "User"

  enum :status, {
    draft: 0,
    sent: 1,
    scheduled: 2,
    failed: 3
  }

  before_create :generate_notification_id

  validates :title, :message, :notification_type, :audience, presence: true

  private

  def generate_notification_id
    last_id = MerchantNotification.last&.id.to_i + 1
    self.notification_id = "NOT#{last_id.to_s.rjust(4, "0")}"
  end
end
