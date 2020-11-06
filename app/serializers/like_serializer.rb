class LikeSerializer < ActiveModel::Serializer
  attributes %i(like_info)

  def like_info
    user_simple_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :like_info))
    object.target_type == "User" ?
    {
      id: object.id,
      target_id: object.target_id,
      target_type: object.target_type, 
      user_id: object.user_id,
      location: object.target&.location&.title,
      name: object.target&.nickname,
      image: object.target&.image_path
    } : 
    {
      id: object.id,
      title: object.target&.title, 
      target_id: object.target_id,
      target_type: object.target_type,
      user_id: object.user_id
    }
  end

end
