class PushNotificationDevice < ApplicationRecord
  validates :device_type, presence: true
  validates :device_token, presence: true
  
  has_many :user_push_notification_devices
  has_many :users, through: :user_push_notification_devices

  enum device_type: %i(android ios)
    
  # @param devices [Array] Array of devices
  # @param data [Hash] Data to be passes with the notification
  def self.push_notification(device, data)
    ios_device_tokens = get_device_tokens(devices, :ios)
    android_device_tokens = get_device_tokens(devices, :android)

    # android
    if android_device_tokens.present?
      options = { registration_ids: android_device_tokens, data: data }
      PushNotify.push(
        PushNotify::APP_NAME[:android],
        options
      )
    end

    # ios
    ios_device_tokens.each do |token|
      options = { device_token: token, data: data, alert: data[:message] }
      PushNotify.push(
        PushNotify::APP_NAME[:ios],
        options
      )
    end
  end

  # @param devices [Array] Array of devices
  # @param device_type [Symbol] type of device. Ex. :ios, :android
  # @return [Array] Array of device tokens
  def self.get_device_tokens(devices, device_type)
    devices.select { |d| d.device_type.to_sym.eql?(device_type) }
    .map(&:device_token).uniq
  end
end
