class User < ApplicationRecord
  USER_COLUMNS = %i(email nickname password password_confirmation)  

  has_secure_password

  validates :email, presence: true
  validates :nickname, presence: true

  has_many :posts
  has_many :user_chats
  has_many :chats, through: :user_chats
  has_many :messages

  belongs_to :group, optional: :true

  enum user_type: %i(normal company)

end