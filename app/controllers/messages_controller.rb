class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_chat, only: %i(index create)
  before_action :check_owner, only: %i(index create)

  def index
    # 현재 유저가 읽지 않은 메시지 가져오기
    @messages = @chat.messages.where.not("check_id @> ?", "{#{current_user.id}}")
    
    # 메시지에 현재 유저가 읽었다고 추가
    @messages.each do |message|
      message.check_id << current_user.id
      message.save!
    end

    # 메시지 렌더
    render json: @messages, status: :ok, scope: {params: create_params}
  end

  def create
    @message = current_user.messages.build message_params
    @message.chat = @chat
    @message.check_id << current_user.id
    @message.save!

    # push notification
    rids = []
    users = []
    @chat.users.each do |user|
      next if user == @current_user
      rids += user.device_list
      users << user.nickname
    end

    Rails.logger.info "From #{current_user.nickname} To #{users}"
    Rails.logger.info "registration ids: #{rids}"
    push_notification(@message.body, current_user.nickname, rids)

    render json: @message, status: :ok, scope: {params: create_params}
  end

  private
  def load_chat
    begin
      @chat = Chat.find(params[:chat_id])
    rescue => e
      Rails.logger.error "ERROR: 없는 채팅입니다. #{log_info}"
      render json: {error: "없는 채팅입니다."}, status: :bad_request
    end
  end

  def message_params
    params.require(:message).permit(Message::MESSAGE_COLUMNS)
  end

  def check_owner
    unless @chat.users.include? current_user
      Rails.logger.error "ERROR: 메시지 권한이 없습니다. #{log_info}"
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end
end
