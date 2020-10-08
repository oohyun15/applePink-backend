class UserSerializer < ActiveModel::Serializer
  has_many :posts
  attributes %i(user_simple_info user_detail_info)

  def user_simple_info
    user_simple_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :user_simple_info))
    {id: object.id, title: object.email, nickname: object.nickname}
  end

  def user_detail_info
    user_detail_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :user_detail_info))
    {id: object.id, title: object.email, nickname: object.nickname, user_type: object.user_type} if user_detail_scope rescue nil
  end

end
