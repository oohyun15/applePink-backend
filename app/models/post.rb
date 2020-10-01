class Post < ApplicationRecord
  POST_COLUMNS = %i(title body price category_id)  

  validates :title, presence: :true
  validates :body, presence: :true
  validates :price, presence: :true

  has_many :chats
  has_many :chat_users, through: :chats, source: :users

  belongs_to :user
  belongs_to :category, optional: true

  enum status: %i(able unable)
end
