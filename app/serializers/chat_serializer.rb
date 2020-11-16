class ChatSerializer < ActiveModel::Serializer
  #has_many :messages  
  attributes %i(chat_info)

  #채팅방 목록들
  def chat_info
    last_message = object.messages&.order(created_at: :desc)&.first
    chat_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :chat_info))
    {
      id: object.id,
      post_id: object.post_id,
      nickname: User.where(id: (object.user_ids - [@instance_options[:user_id]]) )&.pluck(:nickname),
      image: User.find_by(id: (object.user_ids - [@instance_options[:user_id]]) )&.image_path,
      created_time: object.messages_count > 0 ? time_ago_in_words(last_message.created_at) : nil, 
      num_unchecked: object.messages_count > 0 ? object.messages.where.not("check_id @> ?", "{#{@instance_options[:user_id]}}").size : nil, 
      message: object.messages_count > 0 ? last_message.body : nil
    }
  end
end
