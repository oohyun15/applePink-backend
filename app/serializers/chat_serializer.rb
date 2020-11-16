class ChatSerializer < ActiveModel::Serializer
  #has_many :messages  
  attributes %i(chat_info)

  #채팅방 목록들
  def chat_info
    chat_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :chat_info))
    chat_exist? = (object.messages_count > 0)
    {
      id: object.id,
      post_id: object.post_id,
      nickname: User.where(id: (object.user_ids - [@instance_options[:user_id]]) )&.pluck(:nickname),
      image: User.find_by(id: (object.user_ids - [@instance_options[:user_id]]) )&.image_path,
      created_time: chat_exist? ? time_ago_in_words(object.messages.last.created_at) : nil, 
      num_unchecked: chat_exist? 0 ? object.messages.where.not("check_id @> ?", "{#{@instance_options[:user_id]}}").size : nil, 
      message: chat_exist? ? object.messages.last.body : nil
    }
  end
end
