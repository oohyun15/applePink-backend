class PostsController < ApplicationController

  before_action :load_post, only: %i(show edit update destroy)
  before_action :post_params, only: %i(create update)

  def index
    @posts = Post.all
    render json: @posts, status: :ok
  end

  def show
    render json: @post, status: :ok
  end

  def new
    @post = Post.new
    render json: @post, status: :ok
  end
  
  def edit
    render json: @post, status: :ok
  end

  def update
    @post.update(post_params)
    redirect_to post_path(@post)
  end

  def create
    @post = Post.create! post_params
    redirect_to post_path(@post)
  end

  def destroy
    @post.destroy
    redirect_to posts_path
  end

  private
  def post_params
    params.require(:post).permit(Post::POST_COLUMNS)
  end

  def load_post
    @post = Post.find(params[:id])
  end

end
