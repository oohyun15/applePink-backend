class Company < ApplicationRecord
  include ImageUrl
  
  COMPANY_COLUMNS = %i(name phone message image description location_id)

  validates :name, presence: true
  validates :phone, presence: true
  validates :message, presence: true
  # validates :image, presence: true
  validates :description, presence: true
  
  has_many :posts, through: :user
  
  has_one_attached :image

  belongs_to :user
  belongs_to :location
end
