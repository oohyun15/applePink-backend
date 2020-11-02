class Image < ApplicationRecord
  include ImageUrl
  belongs_to :imagable, polymorphic: true, optional: true

  has_one_attached :image
end
