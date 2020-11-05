class UserPushNotificationDevice < ApplicationRecord
  belongs_to :user
  belongs_to :push_notification_device
end
