class PostsController < ApplicationController
  before_action :load_post, only: %i(show update destroy)
  before_action :post_params, only: %i(create update)
  before_action :authenticate_user!
  before_action :check_owner, only: %i(update destroy)

  def index
    @posts = Post.all
    render json: @posts, status: :ok
  end

  def show
    render json: @post, status: :ok
  end
  
  def update
    @post.update(post_params)
    redirect_to post_path(@post)
  end

  def create
    @post = current_user.posts.create! post_params
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

  def check_owner
    if @post.user != current_user
      @msg = "접근권한이 없습니다."
      render json: @msg, status: :unauthorized
    end
  end

end
