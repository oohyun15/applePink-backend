class LikeSerializer < ActiveModel::Serializer
  attributes %i(like_info)

  def like_info
    like_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :like_info))
    object.target_type == "User" ?
    {
      id: object.id,
      target_id: object.target_id,
      target_type: object.target_type, 
      user_id: object.user_id,
      location: object.target&.is_location_auth? ? object.target&.location&.title : nil,
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
