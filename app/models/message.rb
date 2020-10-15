class Message < ApplicationRecord
  include Imagable
 
  MESSAGE_COLUMNS = %i(body) + [images_attributes: %i(imagable_type imagable_id image)]

  belongs_to :chat
  belongs_to :user, optional: :true
  belongs_to :target, class_name: "User", optional: :true

  has_many :user_chats, through: :chat
  has_many :checked_users, through: :user_chats, source: :user
end
