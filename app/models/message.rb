class Message < ApplicationRecord
  include Imagable
 
  MESSAGE_COLUMNS = %i(body) + [images_attributes: %i(imagable_type imagable_id image)]

  belongs_to :chat
  belongs_to :user, optional: :true
end
