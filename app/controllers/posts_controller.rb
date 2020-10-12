class PostsController < ApplicationController
  before_action :load_post, only: %i(show update destroy)
  before_action :post_params, only: %i(create update)
  before_action :authenticate_user!, except: %i(index)
  before_action :check_owner, only: %i(update destroy)

  def index

    if params[:post_type] == "provide" || params[:post_type].nil?
      @posts = Post.provide
    elsif params[:post_type] == "ask"
      @posts = Post.ask
    end
    render json: @posts, status: :ok, scope: {params: create_params}
  end

  def show
    render json: @post, status: :ok, scope: {params: create_params}
  end
  
  def update
    @post.update(post_params)
    render json: @post, status: :ok, scope: {params: create_params}
  end

  def create
    @post = current_user.posts.build post_params
    begin
      @post.able!
      redirect_to post_path(@post), notice: "게시글 생성 완료"
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  end

  def destroy
    begin
      @post.destroy!
      render json: {notice: "채팅방에서 나오셨습니다."}, status: :ok
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  end

  private
  def post_params
    params.require(:post).permit(Post::POST_COLUMNS)
  end

  def load_post
    begin
      @post = Post.find(params[:id])
    rescue => e
      render json: {error: "없는 게시글입니다."}, status: :bad_request
    end
  end

  def check_owner
    if @post.user != current_user
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end

end
