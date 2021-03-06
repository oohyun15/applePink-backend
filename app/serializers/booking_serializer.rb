class BookingSerializer < ActiveModel::Serializer
  attributes %i(booking_info)

  def booking_info
    booking_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :booking_info))
    {
      id: object.id,
      post_id: object.post_id,
      post_image: object.post&.image_path,
      title: object.title,
      product: object.product,
      body: object.body,
      price: object.price,
      acceptance: object.acceptance,
      start_at: object.start_at,
      end_at: object.end_at,
      lent_day: object.lent_day,
      for: object.id == @instance_options[:user_id] ? "consumer" : "provider",
      has_review: object.review.present?,
      result: 
        case object.acceptance
        when "accepted"
          "승인"
        when "rejected"
          "거절"
        when "completed"
          "완료"
        when "waiting"
          "대기 중"         
        end,
      contract: object.contract,
      consumer: {
        nickname: !object.user.nil? ? object.user&.nickname : "탈퇴한 사용자입니다.",
        image: object.user&.image_path,
        birth: object.accepted? || object.completed? ? object.user&.birthday : nil,
        name: object.accepted? || object.completed? ? object.user&.name : nil,
        number: object.accepted? || object.completed? ? object.user&.number : nil,
        sign_datetime: object.accepted? || object.completed? ? object.consumer_sign_datetime : nil
      },
      provider: {
        nickname: !object.post.nil? ?  !object.post&.user.nil? ? object.post&.user&.nickname : "탈퇴한 사용자입니다."  : "삭제된 게시글입니다.",
        image: object.post&.user&.image_path,
        birth: object.accepted? || object.completed? ? object.post&.user&.birthday : nil,
        name: object.accepted? || object.completed? ? object.post&.user&.name : nil,
        number: object.accepted? || object.completed? ? object.post&.user&.number : nil,
        sign_datetime: object.accepted? || object.completed? ? object.provider_sign_datetime : nil
      },
    }
  end
end
