class Message < ApplicationRecord
  belongs_to :chat
  belongs_to :user_chat
  delegate :user, to: :user_chat
end
