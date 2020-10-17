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

  belongs_to :group, optional: :true
  belongs_to :location

  enum gender: %i(no_select man woman)
  enum user_type: %i(normal company)

end