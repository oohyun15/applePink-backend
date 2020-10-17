class Location < ApplicationRecord
  include Positionable

  validates_uniqueness_of :title
  validates_uniqueness_of :position
  
  has_many :users
  has_many :posts
end
