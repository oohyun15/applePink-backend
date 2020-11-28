class Tag < ApplicationRecord
  has_many :taggings
  has_many :users, through: :taggings, source: :taggable, source_type: "User"
end
