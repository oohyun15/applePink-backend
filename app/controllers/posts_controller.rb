class PostsController < ApplicationController
  before_action :load_post, only: %i(show)
  def index
    # 내가 판매하는 상품
    if params[:type] == "selling"
      redirect_to root_path, notice: "로그인을 해야 합니다." unless current_user
      @posts = current_user.posts
    else
      @posts = Post.all
      # 카테고리별 페이지
      if params[:category_id].present?
        @category = Category.find_by(id: params[:category_id])
        @posts = @posts.where(category_id: params[:category_id])
      end
    end
    @posts = @posts.ransack(title_cont: params[:q], m: "or", description_cont: params[:q]).result(distinct: true) if params[:q].present?
    # if params[:order] == "updated_at"
    #   @posts = @posts.order(updated_at: :desc)
    # elsif params[:order] == "price"
    #   @posts = @posts.order(price: :asc)
    # elsif params[:order].blank?
    #   @posts = @posts.order(impressions_count: :desc)
    # end
    @posts = @posts.page(params[:page]).per(20)
  end

  def show

  end

  private
  def load_post
    begin
      @post = Post.find(params[:id])
    rescue => e
      Rails.logger.error "ERROR: 없는 게시글입니다. #{log_info}"
      render json: {error: "없는 게시글입니다."}, status: :bad_request
    end
  end
end
