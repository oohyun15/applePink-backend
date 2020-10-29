class LikeSerializer < ActiveModel::Serializer
  attributes %i(like_info)

  def like_info
    user_simple_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :like_info))
    object.target_type == "User" ?
    {id: object.id, target_id: object.target_id, target_type: object.target_type, 
      user_id: object.user_id,
      location: User.find(object.target_id).location.title,
      name: User.find(object.target_id).nickname,
      image: User.find(object.target_id).image_path
    } : 
    {
      id: object.id, target_id: object.target_id, target_type: object.target_type, user_id: object.user_id
    }
  end

end
