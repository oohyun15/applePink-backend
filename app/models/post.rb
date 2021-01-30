class Post < ApplicationRecord
  include ImageUrl
  include Imagable
  
  POST_COLUMNS = %i(title body product price category_id image post_type contract) + [images_attributes: %i(imagable_type imagable_id image)]

  after_create :check_keywords
  
  scope :has_user, -> { where.not(user_id: nil) }
  scope :has_not_user, -> { where(user_id: nil) }

  formatter = -> value {
    case value
     when 'true'
        Post.has_user.pluck(:id)
      when 'false'
        Post.has_not_user.pluck(:id)
    end
  }

  ransacker(:user_id, formatter: formatter) { |parent| parent.table[:id] }

  validates :title, presence: true#, on: :create
  validates :product, presence: true
  validates :body, presence: true
  validates :price, presence: true
  validates :post_type, presence: true

  has_one_attached :image
  
  has_many :chats, dependent: :destroy
  has_many :chat_users, through: :chats, source: :users
  has_many :bookings, dependent: :destroy
  has_many :likes, as: :target, class_name: "Like", dependent: :destroy
  has_many :reports, class_name: "Report", as: :target, dependent: :destroy
  has_many :reviews, dependent: :destroy

  belongs_to :user
  belongs_to :location, foreign_key: :location_id, primary_key: :position
  belongs_to :category

  scope :normal_post, -> { joins(:user).where('users.user_type = 0') }
  scope :company_post, -> { joins(:user).where('users.user_type = 1') }

  enum status: %i(able unable)
  enum post_type: %i(provide ask)

  def display_name
    self.title
  end

  private
  def calculate_avg
    update_attribute(:rating_avg, self.reviews.average(:rating).to_f)
  end

  def check_keywords
    tags = Tag.includes(:taggings).where(taggings: { taggable_type: "User" }).pluck(:name)
    tags = tags.select{ |tag| self.title.include?(tag) }

    User.tagged_with(tags, any: true).each do |user|
      data = {"type": "keyword", "post_id": "#{self.id}"}
      user.push_notification("등록하신 키워드 알림에 해당하는 물품이 게시되었습니다. \"#{self.title}\"", "[모두나눔] 키워드 알림", user.device_list, data) if user != self.user
    end
  end
end
