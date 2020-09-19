class PostsController < ApplicationController
  def index
    @posts = Post.all
    render json: @posts, status: :ok
  end

  def new
    @post = Post.new
    render json: @post, status: :ok
  end

  def create
    @post = Post.create! post_params
    render json: @post, status: :ok
  end

  private
  def post_params
    params.require(:post).permit(Post::POST_COLUMNS)
  end
end
