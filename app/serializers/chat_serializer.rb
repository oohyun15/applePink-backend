class ChatSerializer < ActiveModel::Serializer
  include CommonSerializer

  attributes %i(chat_info)

  #채팅방 목록들
  def chat_info
    last_message = object.messages&.order(created_at: :desc)&.first
    chat_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :chat_info))
    {
      id: object.id,
      post_id: object.post_id,
      nickname: !is_alone? ? User.where(id: (object.user_ids - [current_user_id]) )&.pluck(:nickname) : "대화 상대 없음",
      image: !is_alone? ? User.find_by(id: (object.user_ids - [current_user_id]) )&.image_path : nil,
      other_users: object.user_ids - [current_user_id],
      created_time: object.messages_count > 0 ? timestamp(last_message.created_at) : nil, 
      num_unchecked: object.messages_count > 0 ? object.messages.where.not("check_id @> ?", "{#{current_user_id}}").size : nil, 
      message: object.messages_count > 0 ? last_message.body : nil
    }
  end

  def current_user_id
    @current_user_id ||= @instance_options[:user_id]
  end

  def is_alone?
    current_user_id.in?(object.user_ids) && object.user_ids.size == 1
  end
end
