class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_chat, only: %i(index create)

  def index
    # 현재 유저가 읽지 않은 메시지 가져오기
    @messages = @chat.messages.where.not("check_id @> ?", "#{current_user.id}")
    
    # 메시지에 현재 유저가 읽었다고 추가
    @messages.each do |message|
      message.check_id << current_user.id
      message.save!
    end

    # 메시지 렌더
    render json: @messages, status: :ok
  end

  def create
    @message = current_user.messages.build message_params
    @message.chat = @chat
    @message.check_id << current_user.id
    @message.save!

    @chat.update!(has_message: :true) unless @chat.has_message

    render json: @message, status: :ok
  end

  private
  def load_chat
    begin
      @chat = Chat.find(params[:chat_id])
    rescue => e
      render json: {error: "없는 채팅입니다."}, status: :bad_request
    end
  end

  def message_params
    params.require(:message).permit(Message::MESSAGE_COLUMNS)
  end
end
