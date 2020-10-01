class PostsController < ApplicationController
  before_action :load_post, only: %i(show update destroy)
  before_action :post_params, only: %i(create update)
  before_action :authenticate_user!
  before_action :check_owner, only: %i(update destroy)

  def index
    @posts = Post.all.order(created_at: :desc)
    render json: @posts, status: :ok
  end

  def show
    render json: @post, status: :ok
  end
  
  def update
    @post.update(post_params)
    redirect_to post_path(@post), notice: "게시글 수정 완료"
  end

  def create
    @post = current_user.posts.build post_params
    @post.able!
    redirect_to post_path(@post), notice: "게시글 생성 완료"
  end

  def destroy
    @post.destroy!
    redirect_to posts_path, notice: "게시글 삭제 완료"
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
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end

end
