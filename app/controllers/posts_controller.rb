class PostsController < ApplicationController
  before_action :load_post, only: %i(show update destroy like)
  before_action :post_params, only: %i(create update)
  before_action :authenticate_user!
  before_action :check_owner, only: %i(update destroy)

  def index
    # 지역 설정
    location_positions = []

    # 특정 지역 검색
    if params[:location_title].present?
      # 1. 파라미터로 지역 찾기
      @location = Location.find_by(title: params[:location_title])
      
      # exception: 만약 없는 동네일 경우
      if @location.nil?
        Rails.logger.debug "ERROR: 존재하지 않는 동네입니다."
        return render json: {error: "존재하지 않는 동네입니다."}, status: :not_found 
      end

      # 2. location_positions에 해당 position 추가
      location_positions << @location.position

    # 사용자 지역 범위로 검색
    else
      # 1. 사용자의 지역을 변수로 받음
      @location = current_user.location

      # 2. 사용자의 지역 검색 범위에 따라 location_positions 추가
      case current_user.location_range
      when "location_alone"
        location_positions << @location.position
      when "location_near"
        location_positions = @location.location_near
      when "location_normal"
        location_positions = @location.location_normal
      when "location_far"
        location_positions = @location.location_far
      end
    end

    # location_ids 구하기
    # location 모델에서 position이 unique하게 가지고 있어 지금처럼 id를 구하는 과정이 오버헤드임
    # 추후에 user 모델에 location_position 이라는 컬럼을 추가해서관리해도 괜찮을 것 같음
    # ex Post.where(post_type: :provide, location_position: location_positions)
    # location_ids = Location.where(position: location_positions).ids

    # location_ids와 post_type에 따른 서비스 분류
    if params[:post_type] == "provide" || params[:post_type].nil?
      @posts = Post.where(post_type: :provide, location_id: location_positions)
    elsif params[:post_type] == "ask"
      @posts = Post.where(post_type: :ask, location_id: location_positions)
    end
    #render json: {
    #  location: @location.title,
    #  location_range: I18n.t("enum.user.location_range.#{current_user.location_range}"),
    #  posts: ActiveModel::Serializer::CollectionSerializer.new(@posts, scope: {params: create_params})
       # scope 적용이 안됨. 수정 필요
    #}#, status: :ok, scope: {params: create_params}

    # 추가적인 검색 조건이 있는 경우
    if params[:q].present?
      @posts = @posts.ransack(params[:q]).result(distinct: true)
    end

    @posts.order(created_at: :desc)
    render json: @posts, status: :ok, scope: { params: create_params, location: {info: true, title: @location.title, range: I18n.t("enum.user.location_range.#{current_user.location_range}")} }, user_id: current_user.id
  end

  def show
    render json: @post, status: :ok, scope: {params: create_params}, user_id: current_user.id
  end
  
  def update
    @post.update(post_params)
    render json: @post, status: :ok, scope: {params: create_params}, user_id: current_user.id
  end

  def create
    @post = current_user.posts.build post_params
    begin
      @post.location = current_user.location
      @post.rent_count = 0
      @post.able!
      render json: @post, status: :ok, scope: {params: create_params}, user_id: current_user.id
    rescue => e
      Rails.logger.debug "ERROR: #{e}"
      render json: {error: e}, status: :bad_request
    end
  end

  def destroy
    begin
      @post.destroy!
      render json: {notice: "게시글을 삭제하셨습니다."}, status: :ok
    rescue => e
      Rails.logger.debug "ERROR: #{e}"
      render json: {error: e}, status: :bad_request
    end
  end

  def like
    user_ids = @post.likes.pluck(:user_id)
    user_nicknames = User.where(id: user_ids).pluck(:nickname)
    return render json: { user_list: user_nicknames }, status: :ok
  end

  private
  def post_params
    params.require(:post).permit(Post::POST_COLUMNS)
  end

  def load_post
    begin
      @post = Post.find(params[:id])
    rescue => e
      Rails.logger.debug "ERROR: 없는 게시글입니다."
      render json: {error: "없는 게시글입니다."}, status: :bad_request
    end
  end

  def check_owner
    if @post.user != current_user
      Rails.logger.debug "ERROR: 게시글 관리 권한이 없습니다."
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end

end
