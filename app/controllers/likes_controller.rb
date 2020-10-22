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

    render json: @likes, status: :ok
  end

  def toggle
    # 좋아요 대상이 자신인 경우
    return render json: {error: "자기 자신은 좋아요를 할 수 없습니다."}, status: :bad_request if current_user == @target

    # 기존에 좋아요를 했을 경우
    if @like = current_user.likes.find_by(target_type: like_params[:target_type], target_id: like_params[:target_id])
      @like.destroy!
      result = "좋아요 취소!"

      # 좋아요가 없을 경우 
    else
      current_user.likes.create! like_params
      result = "좋아요!"
    end

    render json: {
      result: result,
      type: I18n.t("activerecord.models.#{like_params[:target_type].downcase}"),
      size: @target.model_name.name == "User" ? @target.received_likes.size : @target.likes.size,
      target: @target.model_name.name == "User" ? @target.nickname : @target.title
      }, status: :ok
  end

  private

  def check_possible
    params[:like][:target_type] = params[:like][:target_type].capitalize

    return render json: {error: "좋아요를 할 수 없는 객체입니다."}, status: :bad_request if Like::LIKE_MODELS.exclude? like_params[:target_type].capitalize
  end

  def load_target
    begin
      model = like_params[:target_type].capitalize
      @target = model.constantize.find(like_params[:target_id])
    rescue => e
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
      render json: {error: "없는 유저입니다."}, status: :bad_request
    end
  end
end