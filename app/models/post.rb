class Post < ApplicationRecord
  POST_COLUMNS = %i(title body price)
  
  has_many :chats
  has_many :chat_users, through: :chats, source: :users

  belongs_to :user, optional: true
  belongs_to :category, optional: true

  
end
