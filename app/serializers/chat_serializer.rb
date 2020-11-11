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
      created_time: object.has_message ? object.messages.last.created_at : nil, 
      num_unchecked: object.has_message ? object.messages.where.not("check_id @> ?", "{#{@instance_options[:user_id]}}").size : nil, 
      message: object.has_message ? object.messages.last.body : nil
    }
  end

end
