class Post < ApplicationRecord
  include ImageUrl
  include Imagable
  
  POST_COLUMNS = %i(title body price category_id image post_type) + [images_attributes: %i(imagable_type imagable_id image)]
  
  validates :title, presence: true#, on: :create
  validates :body, presence: true
  validates :price, presence: true
  validates :post_type, presence: true

  has_one_attached :image
  has_one :contract, dependent: :destroy
  
  has_many :chats
  has_many :chat_users, through: :chats, source: :users
  has_many :bookings
  has_many :likes, as: :target, class_name: "Like", dependent: :destroy
  has_many :reports, class_name: "Report", as: :target, dependent: :destroy

  belongs_to :user
  belongs_to :location, foreign_key: :location_id, primary_key: :position
  belongs_to :category

  enum status: %i(able unable)
  enum post_type: %i(provide ask)

  def display_name
    self.title
  end
end
