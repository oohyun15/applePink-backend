# Push Notification
class PushNotify
  MSGS = {
    invalid_app_type: 'PLEASE PROVIDE A VALID APP TYPE'
  }
  APP_NAME = {
    android: :android,
    ios: :ios
  }

  # push the message
  # @param type [Symbol] type of app
  # @param app_name [String] Name of the app
  # @param options [Hash] Notification options
  # @return [Array/Boolean]
  def self.push(type, options)
    app = Rpush::Apns::App.find_by_name(type) # Apple developer key needed.
    case type
    when :android
      push_android(app, options)
    when :ios
      push_ios(app, options)
    else
      [false, MSGS[:invalid_app_type]]
    end
  end

  def self.push_android(app, options)
    options = options.slice(:registration_ids, :data).merge(app: app)
    Rpush::Gcm::Notification.new(options).save!
  end

  def self.push_ios(app, options)
    options = options.slice(:device_token, :alert, :data).merge(app: app)
    Rpush::Apns::Notification.new(options).save!
  end
end