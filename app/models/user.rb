class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable
  include ImageUrl

  USER_COLUMNS = %i(email nickname password password_confirmation image)

  has_secure_password

  validates :email, presence: true
  validates :nickname, presence: true

  has_many :posts
  has_many :user_chats
  has_many :chats, through: :user_chats
  has_many :messages
  has_many :bookings
  has_many :received_bookings, through: :posts, source: :bookings
  has_many :likes
  has_many :received_likes, class_name: "Like", as: :target, dependent: :destroy

  accepts_nested_attributes_for :likes

  belongs_to :group, optional: :true
  belongs_to :location, optional: :true

  enum gender: %i(no_select man woman)
  enum user_type: %i(normal company)
  enum location_range: %i(location_alone location_near location_normal location_far)

end