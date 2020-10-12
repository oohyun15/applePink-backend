class ChatSerializer < ActiveModel::Serializer
  #has_many :messages  
  attributes %i(chat_simple_info)

  #채팅방 목록들
  def chat_simple_info
    chat_simple_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :chat_simple_info))
    {id: object.id, created_time: object.messages.last.created_at, message: object.messages.last.body}
  end

end
