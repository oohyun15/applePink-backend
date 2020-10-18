class Category < ApplicationRecord
  include Positionable
  
  has_many :posts
end
