class MessageSerializer < ActiveModel::Serializer
  attributes %i(message_info)

  #채팅방 목록들
  def message_info
    message_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :message_info))
    {id: object.id, created_time: object.created_at, post_id: object.chat.post_id,
      body: object.body, sender: object.user_id}
  end
  
end
