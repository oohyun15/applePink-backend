class LikeSerializer < ActiveModel::Serializer
  attributes %i(like_info)

  def like_info
    user_simple_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :like_info))
    {id: object.id, target_id: object.target_id, target_type: object.target_type, 
      user_id: object.user_id, 
      location: object.target_type == "User" ? User.find(object.target_id).location.title : nil,
      name: object.target_type == "User" ? User.find(object.target_id).nickname : nil
    }
  end

end
