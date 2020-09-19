class PostsController < ApplicationController
  def index
    @posts = Post.all
    render json: @posts, status: :ok
  end

  def show
    @post = Post.find(params[:id])
    render json: @post, status: :ok
  end

  def new
    @post = Post.new
    render json: @post, status: :ok
  end

  def create
    @post = Post.create! post_params
    redirect_to post_path @post
  end

  private
  def post_params
    params.require(:post).permit(Post::POST_COLUMNS)
  end
end
