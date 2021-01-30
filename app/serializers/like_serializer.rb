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
      title: !object.target.nil? ? object.target&.title : "탈퇴한 사용자거나 삭제된 게시글입니다.",
      target_id: !object.target.nil? ? object.target_id : -1,
      target_type: !object.target.nil? ? object.target_type : "탈퇴한 사용자거나 삭제된 게시글입니다.",
      user_id: object.user_id,
      post_image: object.target_type == "Post" ? object.target&.image_path : nil,
      price: object.target_type == "Post" ? object.target&.price : nil
    }
  end

end
