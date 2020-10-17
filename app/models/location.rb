class Location < ApplicationRecord
  validates_uniqueness_of :title
  
  has_many :users
  has_many :posts
end
