class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_chat, only: %i(create)

  def create
    @message = current_user.messages.build message_params
    @message.chat = @chat
    @message.save!

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
