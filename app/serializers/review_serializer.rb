class ReviewSerializer < ActiveModel::Serializer
  attributes %i(review_info)

  def review_info
    review_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :review_info))
    {
      id: object.id,
      body: object.body,
      booking_id: object.booking_id,
      images: object.images.map{ |image| image.image_path },
      user_id: !object.user.nil? ? object.user&.id : -1,
      user_nickname: !object.user.nil? ? object.user&.nickname : "탈퇴한 사용자입니다.",
      user_image: object.user&.image_path,
      rating: object.rating,
      created_at: object.created_at.strftime("%Y년 %m월 %d일"),
      post_title: object.post&.title, 
      post_image: object.post&.image_path
    }
  end
end
