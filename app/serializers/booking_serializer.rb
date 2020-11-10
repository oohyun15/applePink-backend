class BookingSerializer < ActiveModel::Serializer
  attributes %i(booking_info)

  def booking_info
    booking_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :booking_info))
    {
      id: object.id,
      post_id: object.post_id,
      title: object.title,
      body: object.body,
      price: object.price,
      acceptance: object.acceptance,
      start_at: object.start_at,
      end_at: object.end_at,
      lent_day: object.lent_day,
      image: object.user&.image_path,
      result:  
        case object.acceptance
        when "accepted"
          "accepted"
        when "rejected"
          "rejected"
        when "completed"
          "completed"
        when "waiting"
          "waiting"         
        end,
      contract: object.contract
    }
  end
end
