class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable
  include ImageUrl

  USER_COLUMNS = %i(email nickname password password_confirmation image)

  has_secure_password

  validates :email, presence: true
  validates :nickname, presence: true

  acts_as_taggable_on :devices
  
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

  accepts_nested_attributes_for :likes

  belongs_to :group, optional: true, counter_cache: true
  belongs_to :location, foreign_key: :location_id, primary_key: :position, optional: true

  enum gender: %i(no_select man woman)
  enum user_type: %i(normal company)
  enum location_range: %i(location_alone location_near location_normal location_far)
  enum device_type: %i(ios android unknown)

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
  # 수정수정수정수정수정 저 그지같은 push notification 관련 다 지워라 씨이발
  def add_device_info(attributes)
    return unless attributes.present? && attributes[:device_type].present? && attributes[:device_token].present?
    self.device_Type = attributes[:device_type]
    self.device_list.add(attributes[:device_token])
    self.save!
  end

  def push_notification(body, title)
    begin
      registration_ids = self.device_list

      # check devices
      if registration_ids.blank?
        Rails.logger.debug "ERROR: No available devices."
        return nil
      end

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
      Rails.logger.debug "ERROR: #{e}"
      return nil
    end
  end
end
