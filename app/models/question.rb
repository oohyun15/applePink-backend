class Question < ApplicationRecord
  include Imagable

  QUESTION_COLUMNS = %i(title body contact email) + [images_attributes: %i(imagable_type imagable_id image)]

  belongs_to :user
end
