class Chat < ApplicationRecord

  has_many :user_chats
  has_many :users, through: :user_chats
  has_many :messages, dependent: :destroy

  accepts_nested_attributes_for :messages, allow_destroy: true
  
  belongs_to :post
end
