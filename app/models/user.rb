class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable
  include ImageUrl

  USER_COLUMNS = %i(email nickname password password_confirmation image name birthday number)

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
  has_many :messages, dependent: :destroy
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

 
end
