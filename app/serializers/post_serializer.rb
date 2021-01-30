require 'action_view'
require 'action_view/helpers'
include ActionView::Helpers::DateHelper

class PostSerializer < ActiveModel::Serializer
  include CommonSerializer  
  
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
      image_detail: object.images.map{ |image| image.image_path },
      location: object.location&.title,
      status: object.status,
      likes_count: object.likes_count,
      like_check: object.likes&.pluck(:user_id).include?(@instance_options[:user_id]),
      rent_count: object.rent_count,
      contract: object.contract,
      created_at: object.created_at.strftime("%Y-%m-%d %H:%M"),
      updated_at: object.updated_at.strftime("%Y-%m-%d %H:%M"),
      created_at_ago: timestamp(object.created_at),
      updated_at_ago: timestamp(object.updated_at),
      is_booked: is_booked,
      rating: object.rating_avg.round(1),
      expiration_date: object.unable? ? object.bookings&.rent&.first&.end_at : nil
    }
  end

  def location_info
    {title: scope.dig(:location, :title), range: scope.dig(:location, :range)} if scope.dig(:location, :info)
  end

end
