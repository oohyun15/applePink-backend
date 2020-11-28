require 'net/https'
require 'uri'

module Cafe24Sms
  module SendSms
    def send_sms(options)
      url = URI.parse(Configuration::SMS_URL)
      req = Net::HTTP::Post.new(url.path)
      req.set_form_data(_form_data(options), '&')

      http_session = Net::HTTP.new(url.host, url.port)
      http_session.use_ssl = true
      http_session.start {|http| http.request(req)}
    end
    
    def _form_data(options)
      { :sms_url => Configuration::SMS_URL,
        :user_id => Configuration::SMS_URER_ID,
        :secure => Configuration::SMS_SECURE,
        :sphone1 => Configuration::SMS_SPHONE1,
        :sphone2 => Configuration::SMS_SPHONE2,
        :sphone3 => Configuration::SMS_SPHONE3
      }.merge!(options)
    end
    
    def remaining_sms
      auth_data = {:user_id => self.user_id, :secure => self.secure}
      Net::HTTP.post_form(URI.parse(Configuration::SMS_REMAIN_URL), auth_data)
    end
  end
end