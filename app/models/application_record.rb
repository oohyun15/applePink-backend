class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.enum_selectors(column_name)
    I18n.t("enum.#{self.name.underscore}.#{column_name}").invert rescue []
  end

  def push_notification(body, title, registration_ids = (self.device_list rescue nil))
    begin
      # check devices
      if registration_ids.blank?
        Rails.logger.error "ERROR: No available devices. #{log_info}"
        return nil
      end

      Rails.logger.info "Registration ids: #{registration_ids}"
      # initialize FCM
      app = FCM.new(ENV['FCM_SERVER_KEY'])

      # options
      options = {
        "notification": {
          "title": "#{title}",
          "body": "#{body}"
        }
      }

      # send notification
      app.send(registration_ids, options)

    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      return nil
    end
  end
end
