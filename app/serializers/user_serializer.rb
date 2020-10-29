class UserSerializer < ActiveModel::Serializer
  has_many :posts
  attributes %i(user_info)

  def user_info
    user_simple_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :user_info))
    {id: object.id, title: object.email, nickname: object.nickname, location_title: object.location&.title, expire_time: object.expire_time}
  end

end
