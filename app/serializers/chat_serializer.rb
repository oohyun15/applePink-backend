class ChatSerializer < ActiveModel::Serializer
  #has_many :messages  
  attributes %i(chat_info)

  #채팅방 목록들
  def chat_info
    chat_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :chat_info))
    {
      id: object.id,
      post_id: object.post_id,
      nickname: User.where(id: (object.user_ids - [@instance_options[:user_id]]) )&.pluck(:nickname),
      created_time: object.messages_count > 0 ? time_ago_in_words(object.messages.last.created_at) : nil, 
      num_unchecked: object.messages_count > 0 ? object.messages.where.not("check_id @> ?", "{#{@instance_options[:user_id]}}").size : nil, 
      message: object.messages_count > 0 ? object.messages.last.body : nil
    }
  end
end
