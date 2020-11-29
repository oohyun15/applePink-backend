class UserSerializer < ActiveModel::Serializer
  attributes %i(user_info)

  def user_info
    user_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :user_info))
    {
      id: object.id,
      email: object.email,
      nickname: object.nickname,
      image: object.image_path,
      location_title: object.is_location_auth? ? object.location&.title : nil,
      expire_time: object.expire_time,
      likes_count: object.likes_count,
      image: object.image.present? ? object.image.url : "",
      name: object.name,
      birthday: object.birthday,
      number: object.number,
      is_company: object.is_company?,
      company_id: object.company&.present? ? object.company.id : nil,
      group: object.group&.title,
      avg: object.received_reviews.average(:rating).to_f.round(1),
      range: 
        case object.location_range
        when "location_alone"
          "자기 동네만"
        when "location_near"
          "가까운 동네까지"
        when "location_normal"
          "중간 동네까지"
        when "location_far"
          "먼 동네까지"         
        end
    }
  end

end
