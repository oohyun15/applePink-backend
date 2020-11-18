class BookingSerializer < ActiveModel::Serializer
  attributes %i(booking_info)

  def booking_info
    booking_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :booking_info))
    {
      id: object.id,
      post_id: object.post_id,
      title: object.title,
      product: object.product,
      body: object.body,
      price: object.price,
      acceptance: object.acceptance,
      start_at: object.start_at,
      end_at: object.end_at,
      lent_day: object.lent_day,
      image: object.user&.image_path,
      for: object.id == @instance_options[:user_id] ? "consumer" : "provider",
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
        birth: object.accepted? || object.completed? ? object.user&.birthday : nil,
        name: object.accepted? || object.completed? ? object.user&.name : nil,
        number: object.accepted? || object.completed? ? object.user&.number : nil,
        sign_datetime: object.accepted? || object.completed? ? object.consumer_sign_datetime : nil
      },
      provider: {
        birth: object.accepted? || object.completed? ? object.post&.user&.birthday : nil,
        name: object.accepted? || object.completed? ? object.post&.user&.name : nil,
        number: object.accepted? || object.completed? ? object.post&.user&.number : nil,
        sign_datetime: object.accepted? || object.completed? ? object.provider_sign_datetime : nil
      },
    }
  end
end
