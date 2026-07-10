# app/models/privacy_setting.rb
class PrivacySetting < ApplicationRecord
  belongs_to :user
end
