class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable
  include ImageUrl

  USER_COLUMNS = %i(email nickname password password_confirmation image)

  has_secure_password

  validates :email, presence: true
  validates :nickname, presence: true
  
  validates_uniqueness_of :email
  validates_uniqueness_of :nickname

  has_one :company, dependent: :destroy
  has_one :identity, dependent: :destroy

  has_one_attached :image
  
  has_many :posts
  has_many :user_chats
  has_many :chats, through: :user_chats
  has_many :messages
  has_many :bookings
  has_many :received_bookings, through: :posts, source: :bookings
  has_many :likes
  has_many :received_likes, class_name: "Like", as: :target, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :received_reports, class_name: "Report", as: :target, dependent: :destroy
  has_many :schedules
  has_many :questions
  has_many :user_push_notification_devices, dependent: :destroy
  has_many :push_notification_devices, through: :user_push_notification_devices

  accepts_nested_attributes_for :likes

  belongs_to :group, optional: :true
  belongs_to :location, foreign_key: :location_id, primary_key: :position, optional: :true

  enum gender: %i(no_select man woman)
  enum user_type: %i(normal company)
  enum location_range: %i(location_alone location_near location_normal location_far)

  def display_name
    self.nickname
  end

  def is_company?
    self.company.present? && self.company&.approve
  end

  def is_location_auth?
    self.expire_time.present? && (self.expire_time > Time.current rescue false)
  end

  # To add device info: type & token
  # @param attributes [Hash] device informations
  def add_device_info(attributes)
    return unless attributes.present? && attributes[:device_type].present? && attributes[:device_token].present?

    device_attr = attributes.slice(:device_type, :device_token)
    device_params = {
      device_type: PushNotificationDevice.device_types[device_attr[:device_type]],
      device_token: device_attr[:device_token]
    }

    device = PushNotificationDevice.where(device_params).first_or_initialize

    devices = push_notification_devices
    return if devices.include?(device)
    self.push_notification_devices << device
  end

  def push_notification(message)
    begin
      devices = self.push_notification_devices

      if devices.blank?
        Rails.logger.debug "ERROR: No available devices."
        return nil
      end
      data = {
        message: message,
        user_id: self.id
      }
      
      PushNotificationDevice.push_notification(devices, data)
    rescue => e
      Rails.logger.debug "ERROR: #{e}"
      render json: {error: e}, status: :internal_server_error
    end
  end

  def image_from_url(url)
    self.image = URI.parse(url)
  end
end
