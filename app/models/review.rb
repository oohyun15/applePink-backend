class Review < ApplicationRecord
  belongs_to :users, counter_cache: true
  belongs_to :posts, counter_cache: true
  belongs_to :booking
end
