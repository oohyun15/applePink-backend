class PushNotificationDevice < ApplicationRecord
  validates :device_type, presence: true
  validates :device_token, presence: true
  
  has_many :user_push_notification_devices
  has_many :users, through: :user_push_notification_devices

  enum device_type: %i(android ios)
end
