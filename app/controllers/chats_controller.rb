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
    render json: @chat, status: :ok
  end

  def create
    if user = @post.chat_users.find_by(id: current_user.id)
      @chat = user.chats.find_by(post_id: @post.id)
    else
      @chat = @post.chats.create!
      UserChat.create!(user_id: current_user.id, chat_id: @chat.id)
      UserChat.create!(user_id: @post.user.id, chat_id: @chat.id)
    end
    redirect_to chat_path @chat, notice: "채팅 생성 완료"
  end

  private
  def load_post
    @chat = Chat.find(params[:id])
  end

  def load_post
    @post = Post.find(params[:post_id])
  end

  def check_owner
    if @post.user != current_user
      redirect_to :back, notice: "권한이 없습니다."
      end
    end
  end
end
