class Contract < ApplicationRecord

  CONTRACT_COLUMNS = %i(start_at end_at post_id booking_id)

  belongs_to :post
  
end
