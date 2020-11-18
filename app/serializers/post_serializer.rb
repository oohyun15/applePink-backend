require 'action_view'
require 'action_view/helpers'
include ActionView::Helpers::DateHelper

class PostSerializer < ActiveModel::Serializer
  #보여줄 attribute들을 설정함.
  
  has_one :user
  attributes %i(post_info location_info)
  
  #조건문이 없으니 default가 됨
  def post_info
    # 현재 사용자가 해당 게시물에 예약(상태가 대기 중인 것만)을 한 상태인지 확인하는 것
    is_booked = object.bookings&.where(user_id: @instance_options[:user_id])&.waiting&.present?
    post_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :post_info))
    {
      id: object.id,
      #user_id: object.user_id,
      title: object.title,
      body: object.body,
      product: object.product,
      price: object.price, 
      post_type: object.post_type,
      category: object.category&.title,
      category_id: object.category_id,
      image: object.image_path,
      location: object.location&.title,
      status: object.status,
      likes_count: object.likes_count,
      like_check: object.likes&.pluck(:user_id).include?(@instance_options[:user_id]),
      rent_count: object.rent_count,
      contract: object.contract,
      created_at: object.created_at.strftime("%Y-%m-%d %H:%M"),
      updated_at: object.updated_at.strftime("%Y-%m-%d %H:%M"),
      created_at_ago: time_ago_in_words(object.created_at)+" 전",
      updated_at_ago: time_ago_in_words(object.updated_at)+" 전",
      is_booked: is_booked
    }
  end

  def location_info
    {title: scope.dig(:location, :title), range: scope.dig(:location, :range)} if scope.dig(:location, :info)
  end

end
