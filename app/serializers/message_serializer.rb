class MessageSerializer < ActiveModel::Serializer
  attributes %i(message_info)

  #채팅방 목록들
  def message_info
    message_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :message_info))
    {
      id: object.id,
      created_time: object.created_at,
      chat_id: object.chat&.id,
      body: object.body,
      sender: {
        id: object.user_id,
        image: object.user&.image_path,
      },
    }
  end

end
