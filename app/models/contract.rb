class Contract < ApplicationRecord

  CONTRACT_COLUMNS = %i(start_at end_at body post_id)

  belongs_to :post
  
end
