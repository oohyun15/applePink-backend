class Question < ApplicationRecord
  include Imagable

  QUESTION_COLUMNS = %i(title body contact) + [images_attributes: %i(imagable_type imagable_id image)]

  validates :title, presence: true
  validates :body, presence: true
  validates :contact, presence: true

  belongs_to :user
end
