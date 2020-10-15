class Message < ApplicationRecord
  include Imagable
 
  MESSAGE_COLUMNS = %i(body) + [images_attributes: %i(imagable_type imagable_id image target_id)]

  belongs_to :chat
  belongs_to :user, optional: :true
  belongs_to :target, class_name: "User", optional: :true
end
