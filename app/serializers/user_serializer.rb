class UserSerializer < ActiveModel::Serializer
  attributes %i(user_info)

  def user_info
    user_simple_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :user_info))
    {
      id: object.id,
      title: object.email,
      nickname: object.nickname,
      location_title: object.is_location_auth? ? object.location&.title : nil,
      expire_time: object.expire_time,
      likes_count: object.likes_count
    }
  end

end
