class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_target, only: %i(toggle)

  def toggle
    # 기존에 좋아요를 했을 경우
    if @like = current_user.likes.find_by(target_type: like_params[:target_type], target_id: like_params[:target_id])
      @like.destroy!
      result = "좋아요 취소!"

      # 좋아요가 없을 경우 
    else
      current_user.likes.create! like_params
      result = "좋아요!"
    end

    render json: { result: result, size: @target.likes.size, type: I18n.t("activerecord.models.#{like_params[:target_type].downcase}") }, status: :ok
  end

  private

  def load_target
    begin
      @target = like_params[:target_type].constantize.find(like_params[:target_id])
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  end

  def like_params
    params.require(:like).permit(:target_id, :target_type)
  end
end
