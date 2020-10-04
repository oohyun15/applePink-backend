class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_chat, only: %i(show destroy)
  before_action :load_post, only: %i(create)
  before_action :check_owner, only: %i(show destroy)

  def index
    @chats = current_user.chats
    render json: @chats, status: :ok
  end

  def show
    render json: {
      notice: params[:notice],
      chat: @chat,
      post: @chat.post,
      users: @chat.users,
      }, status: :ok
  end

  def create
    if current_user == @post.user
      render json: {error: "자신의 게시글에 대한 채팅은 생성할 수 없습니다."}, status: :bad_request
    else
      @chat = current_user.chats.find_or_create_by!(post_id: @post.id)
      unless @chat.users.include?(@post.user)
        @chat.users << @post.user
      end
      redirect_to chat_path @chat, notice: "거래 시 직거래가 아닌 방법으로 유도 시..."
    end
  end

  def destroy
    @chat.destroy!
    redirect_to chats_path, notice: "채팅 삭제 완료"
  end

  private
  def load_chat
    begin
      @chat = Chat.find(params[:id])
    rescue => e
      render json: {error: "없는 채팅입니다."}, status: :bad_request
    end
  end

  def load_post
    begin
      @post = Post.find(params[:post_id])
    rescue => e
      render json: {error: "없는 게시글입니다."}, status: :bad_request
    end
  end

  def check_owner
    unless @chat.users.include? current_user
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end
end
