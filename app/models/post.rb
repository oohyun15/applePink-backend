class Post < ApplicationRecord
  include ImageUrl
  include Imagable
  
  POST_COLUMNS = %i(title body price category_id image post_type) + [images_attributes: %i(imagable_type imagable_id image)]
  
  validates :title, presence: :true
  validates :body, presence: :true
  validates :price, presence: :true
  validates :post_type, presence: :true

  has_many :chats
  has_many :chat_users, through: :chats, source: :users
  has_many :bookings
  has_many :likes, as: :target, class_name: "Like", dependent: :destroy

  belongs_to :user
  belongs_to :location, foreign_key: :location_id, primary_key: :position
  belongs_to :category, optional: true

  enum status: %i(able unable)
  enum post_type: %i(provide ask)
end
