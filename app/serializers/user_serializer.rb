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
      number: object.number
    }
  end

end
