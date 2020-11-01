class Like < ApplicationRecord
  LIKE_MODELS = %w(User Post Location)
  
  belongs_to :user
  belongs_to :target, polymorphic: true, counter_cache: true
end
