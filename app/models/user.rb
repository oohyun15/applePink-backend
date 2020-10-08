class User < ApplicationRecord
  include ImageUrl
  include Imagable

  USER_COLUMNS = %i(email nickname password password_confirmation image) + [images_attributes: %i(imagable_type imagable_id image)]  

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