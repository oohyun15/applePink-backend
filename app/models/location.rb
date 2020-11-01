class Location < ApplicationRecord
  include Positionable

  validates_uniqueness_of :title
  validates_uniqueness_of :position
  
  has_many :users, foreign_key: :location_id, primary_key: :position
  has_many :posts, foreign_key: :location_id, primary_key: :position
  has_many :likes, as: :target, class_name: "Like", dependent: :destroy

  def display_name
    self.title
  end
end
