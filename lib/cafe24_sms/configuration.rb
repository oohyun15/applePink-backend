  module Cafe24Sms
  module Configuration
    SMS_URL = "https://sslsms.cafe24.com/sms_sender.php"
    SMS_REMAIN_URL = "http://sslsms.cafe24.com/sms_remain.php"
    SMS_USER_ID = ENV["SMS_USER_ID"]
    SMS_SECURE = ENV["SMS_SECURE"]
    SMS_SPHONE1 = ENV["SMS_SPHONE1"]
    SMS_SPHONE2 = ENV["SMS_SPHONE2"]
    SMS_SPHONE3 = ENV["SMS_SPHONE3"]

    attr_accessor :user_id, :secure, :sphone1, :sphone2, :sphone3

    # Convenience method to allow configuration options to be set in a block
    def configure
      yield self
    end
  end
end