class Page < ApplicationRecord
  enum page_type: %i(privacy tos location)
end
