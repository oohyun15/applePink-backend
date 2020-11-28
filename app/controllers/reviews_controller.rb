class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_booking, only: %i(create update)
  before_action :load_review, only: %i(update destroy)
  before_action :check_owner, only: %i(update destroy)

  def index
    begin
      if params[:post_id].present?
        @reviews = Post.find(params[:post_id]).reviews
      elsif params[:user_id].present?
        @reviews = params[:received] == "true" ? User.find(params[:user_id]).received_reviews : User.find(params[:user_id]).reviews
      else
        Rails.logger.error "ERROR: 리뷰를 볼 대상을 정하세요"
        return render json: {error: "ERROR: 리뷰를 볼 대상을 정하세요"}, status: :bad_request
      end
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      return render json: {error: e}, status: :bad_request
    end

    return render json: @reviews, status: :ok, scope: {params: create_params}
  end

  def create
    unless @booking.acceptance == "completed"
      Rails.logger.error "ERROR: 예약이 완료되지 않으면 리뷰를 할 수 없습니다. #{log_info}"
      return render json: {error: "예약이 완료되지 않으면 리뷰를 할 수 없습니다."}, status: :not_acceptable 
    end

    begin
      @review = @booking.build_review review_params
      @review.save!
      @post = @booking.post
      # 새로운 평균 평점 계산
      #avg = (@post.rating_avg * @post.reviews_count + @review.rating) / (@post.reviews_count + 1)
      @post.send(:calculate_avg)
      #@post.update!(rating_avg: avg)

      return render json: @review, status: :ok, scope: {params: create_params}
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      render json: {error: e}, status: :bad_request
    end

  end

  def update
    before_rating = @review.rating

    begin
      @review.update! review_params

      @post = @booking.post
      @post.send(:calculate_avg)
      #avg = (@post.rating_avg * @post.reviews_count - before_rating + @review.rating) / @post.reviews_count
      #@post.update!(rating_avg: avg)

      return render json: @review, status: :ok, scope: {params: create_params}
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      render json: {error: e}, status: :bad_request
    end
  end

  def destroy
    begin
      @review.destroy!

      @post = @booking.post
      # 새로운 평균 평점 계산 
      @post.send(:calculate_avg)

      render json: {notice: "리뷰를 삭제하셨습니다."}, status: :ok
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      render json: {error: e}, status: :bad_request
    end
  end

  private

  def review_params
    review_param = params.require(:review).permit(Review::REVIEW_COLUMNS)
    extra = {
      user_id: current_user.id,
      post_id: @booking.post.id
    }
    result = review_param.merge!(extra)
    Rails.logger.error result
    return result
  end

  def load_booking
    begin
      @booking = Booking.find(params[:review][:booking_id])
    rescue => e
      Rails.logger.error "ERROR: 없는 예약입니다. #{log_info}"
      render json: {error: "없는 예약입니다."}, status: :bad_request
    end
  end

  def load_review
    begin
      @review = Review.find(params[:id])
    rescue => e
      Rails.logger.error "ERROR: 없는 리뷰입니다. #{log_info}"
      render json: {error: "없는 리뷰입니다."}, status: :bad_request
    end
  end

  def check_owner
    if @review.user != current_user
      Rails.logger.error "ERROR: 리뷰 관리 권한이 없습니다. #{log_info}"
      render json: { error: "리뷰 관리 권한이 없습니다." }, status: :unauthorized
    end
  end
end
