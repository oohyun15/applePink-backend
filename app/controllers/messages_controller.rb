class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_chat, only: %i(index create)

  def index
    @messages = @chat.messages.where(:is_checked < @chat.users.size && :user_id != current_user.id).order(created_at: :asc)
    @messages.increment(:is_checked)

    render json: @messages, status: :ok
  end

  def create
    @message = current_user.messages.build message_params
    @message.chat = @chat
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
