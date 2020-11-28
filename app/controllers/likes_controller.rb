class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_possible, only: %i(toggle)
  before_action :load_target, only: %i(toggle)
  before_action :load_user, only: %i(index)

  def index
    if params[:target_type].present?
      @likes = @user.likes.where(target_type: params[:target_type].capitalize)
    else
      @likes = @user.likes
    end

    render json: @likes, status: :ok, scope: {params: create_params}
  end

  def toggle
    # 좋아요 대상이 자신인 경우
    if (@target.user rescue @target) == current_user 
      Rails.logger.error "ERROR: 자기 자신은 좋아요를 할 수 없습니다. #{log_info}"
      return render json: {error: "자기 자신은 좋아요를 할 수 없습니다."}, status: :bad_request 
    end

    begin
      # 기존에 좋아요를 했을 경우
      if @like = current_user.likes.find_by(target_type: like_params[:target_type], target_id: like_params[:target_id])
        @like.destroy!
        result = "false"
  
        # 좋아요가 없을 경우 
      else
        current_user.likes.create! like_params
        result = "true"
      end
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      return render json: {error: e}, status: :bad_request
    end

    #기존의 target의 likes_count는 counter_cache에 의해 업데이트되지 않은 상태임.
    #따라서 업데이트된 likes_count를 얻으려면 @target을 다시 업데이트해야 함.
    load_target

    render json: {
      result: result,
      type: I18n.t("activerecord.models.#{like_params[:target_type].downcase}"),
      size: @target.likes_count,
      target: @target.display_name
      }, status: :ok
  end

  private

  def check_possible
    params[:like][:target_type] = params[:like][:target_type].capitalize
    
    if Like::LIKE_MODELS.exclude? like_params[:target_type].capitalize
      Rails.logger.error "ERROR: 좋아요를 할 수 없는 객체입니다. #{log_info}"
      return render json: {error: "좋아요를 할 수 없는 객체입니다."}, status: :bad_request 
    end
  end

  def load_target
    begin
      model = like_params[:target_type].capitalize
      @target = model.constantize.find(like_params[:target_id])
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      render json: {error: e}, status: :bad_request
    end
  end

  def like_params
    params.require(:like).permit(:target_id, :target_type)
  end

  def load_user
    begin
      @user = User.find(params[:user_id])
    rescue => e
      Rails.logger.error "ERROR: 없는 유저입니다. #{log_info}"
      render json: {error: "없는 유저입니다."}, status: :bad_request
    end
  end
end
