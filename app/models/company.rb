class Company < ApplicationRecord
  include ImageUrl
  
  COMPANY_COLUMNS = %i(name phone message image description location_id title business_registration business_address biz_type category)

  validates :name, presence: true
  validates :phone, presence: true
  validates :message, presence: true
  # validates :image, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :business_registration, presence: true
  validates :business_address, presence: true
  validates :biz_type, presence: true
  validates :category, presence: true
  
  has_many :posts, through: :user
  
  has_one_attached :image

  belongs_to :user
  belongs_to :location
end
