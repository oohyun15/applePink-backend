class Review < ApplicationRecord
  include Imagable
  REVIEW_COLUMNS = %i(body rating booking_id) + [images_attributes: %i(imagable_type imagable_id image)]

  belongs_to :user, counter_cache: true
  belongs_to :post, counter_cache: true
  belongs_to :booking
end
