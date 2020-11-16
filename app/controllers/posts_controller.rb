class PostsController < ApplicationController
  before_action :load_post, only: %i(show update destroy like)
  before_action :authenticate_user!
  before_action :check_owner, only: %i(update destroy)

  def index
    begin
      # 지역 설정
      location_positions = []
  
      # 특정 지역 검색
      if params[:location_title].present?
        # 1. 파라미터로 지역 찾기
        @location = Location.find_by(title: params[:location_title])
        
        # exception: 만약 없는 동네일 경우
        if @location.nil?
          Rails.logger.error "ERROR: 존재하지 않는 동네입니다. #{log_info}"
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
  
      # order: created_at desc
      @posts = @posts.order(created_at: :desc)
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      return render json: {error: e}, status: :bad_request
    end
    
    # 추가적인 검색 조건이 있는 경우
    if params[:q].present?
      @posts = @posts.ransack(params[:q]).result(distinct: true)
    end

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
      @post.contract = "제 1 조 본 계약에서 대여물건이라 함은 계약서 상단에 기재된 것을 말한다.\n
      제 2 조 대여물건의 대여료는 금 --원으로 정하고 '을'은 계약과 동시에 '갑'에게 지급한다.\n
      제 3 조 대여물건에 관한 화재보험료는 '을'이 부담하고 화재보험금의 수취인 명의는 '갑'으로 한다.\n
      제 4 조 '을'은 '갑'의 동의 없이 대여물건을 타인에게 판매, 양도, 대여할 수 없다.\n
      제 5 조 '을'은 대여물건에 대하여 항상 최선의 주의를 하며 선량한 관리자의 주의로써 상용하고 손상, 훼손하지 않도록 노력한다. 만약 '을'의 귀책사유로 손해가 발생한 경우는 즉시 '갑'에게 보고하고 '을'의 비용으로 완전히 보상한다.\n
      제 6 조 '을'은 '갑'의 허가 없이 대여물건의 개조 또는 개수를 할 수 없다.\n
      제 7 조 본 계약이 완료했을 경우 '을'은 즉시 대여물건을 보수완비하고 '갑'에게 반환한다.\n
      제 8 조 전조 각항에 위반할 경우 '갑'은 '을'에 대한 보상 없이 '갑'의 단독의사로 계약을 해제할 수 있다.\n
      제 9 조 본 계약의 조항 이외의 분쟁이 발생하였을 때는 '갑'과 '을'이 협의하여 정한다."
      @post.able!
      render json: @post, status: :ok, scope: {params: create_params}, user_id: current_user.id
    rescue => e
      Rails.logger.error "ERROR: #{@post.errors&.first&.last} #{log_info}"
      render json: {error: @post.errors&.first&.last}, status: :bad_request
    end
  end

  def destroy
    begin
      @post.destroy!
      render json: {notice: "게시글을 삭제하셨습니다."}, status: :ok
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
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
    is_heic?(:image) ? params.require(:post).permit(Post::POST_COLUMNS).merge(image: heic2png(params[:post][:image].path)) 
    : params.require(:post).permit(Post::POST_COLUMNS)
  end

  def load_post
    begin
      @post = Post.find(params[:id])
    rescue => e
      Rails.logger.error "ERROR: 없는 게시글입니다. #{log_info}"
      render json: {error: "없는 게시글입니다."}, status: :bad_request
    end
  end

  def check_owner
    if @post.user != current_user
      Rails.logger.error "ERROR: 게시글 관리 권한이 없습니다. #{log_info}"
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end

end
