class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_location, only: %i(count)
  before_action :load_chat, only: %i(show destroy)
  before_action :load_post, only: %i(create)
  before_action :check_owner, only: %i(show destroy)

  def index
    @chats = current_user.chats.where("messages_count > 0")
    @chats = @chats.includes(:messages).order("messages.created_at desc")
    render json: @chats, status: :ok, scope: {params: create_params}, user_id: current_user.id 
  end

  #def show
  #  render json: {
  #    notice: params[:notice].present? ? params[:notice] : "",
  #    chat: @chat,
  #    post: @chat.post,
  #    users: @chat.users,
  #    }, status: :ok
  #end

  def create
    if current_user == @post.user
      
      # 자기가 쓴 게시글에 채팅 생성 시
      Rails.logger.error "ERROR: 자신의 게시글에 대한 채팅은 생성할 수 없습니다. #{log_info}"
      render json: {error: "자신의 게시글에 대한 채팅은 생성할 수 없습니다."}, status: :bad_request
    else
      # 기존에 생성한 채팅방 있으면 그걸로 불러옴
      @chat = current_user.chats.find_or_create_by!(post_id: @post.id)
      
      # 처음 채팅 시
      unless @chat.users.include?(@post.user)
        @chat.users << @post.user
      end
      
      # 채팅방 생성 성공
      #redirect_to chat_messages_path @chat, notice: "거래 시 직거래가 아닌 방법으로 유도 시..."
      render json: @chat, status: :ok, scope: {params: create_params}, user_id: current_user.id
    end
  end

  def destroy
    begin
      @chat.user_chats.where(user_id: current_user.id).take.destroy!
      @chat.destroy! if @chat.users.empty?
      render json: {notice: "채팅방에서 나오셨습니다."}, status: :ok
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      render json: {error: e}, status: :bad_request
    end
  end

  def count 
    total = 0

    current_user.chats.each do |chat|
      if chat.messages_count > 0
        total += chat.messages.where.not("check_id @> ?", "{#{current_user.id}}").size
      end
    end

    return render json: {total: total}, status: :ok
  end

  private
  def load_chat
    begin
      @chat = Chat.find(params[:id])
    rescue => e
      Rails.logger.error "ERROR: 없는 채팅입니다. #{log_info}"
      render json: {error: "없는 채팅입니다."}, status: :bad_request
    end
  end

  def load_post
    begin
      @post = Post.find(params[:post_id])
    rescue => e
      Rails.logger.error "ERROR: 없는 게시글입니다. #{log_info}"
      render json: {error: "없는 게시글입니다."}, status: :bad_request
    end
  end

  def check_owner
    unless @chat.users.include? current_user
      Rails.logger.error "ERROR: 채팅을 볼 권한이 없습니다. #{log_info}"
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end
end
