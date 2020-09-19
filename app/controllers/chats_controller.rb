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
    @chat = current_user.chats.create!    
    @post.user.user_chats.create!(chat_id: @chat.id)

    redirect_to chat_path @chat
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
      redirect_to root_path
      end
    end
  end
end
