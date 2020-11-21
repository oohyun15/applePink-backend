class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_booking, only: %i(create destroy)
  before_action :load_review, only: %i(update destroy)

  def create
    unless @booking.acceptance == "completed"
      Rails.logger.error "ERROR: 예약이 완료되지 않으면 리뷰를 할 수 없습니다. #{log_info}"
      return render json: {error: "예약이 완료되지 않으면 리뷰를 할 수 없습니다."}, status: :not_acceptable 
    end

    @review = @booking.review.build review_params
    begin
      @review.save!
      @post = @booking.post
      # 새로운 평균 평점 계산
      avg = (@post.rating_avg * (@post.reviews_count - 1)) / @post.reviews_count
      @post.update!(rating_avg: avg)
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
      avg = (@post.rating_avg - before_rating + @review.rating) / @post.reviews_count
      @post.update!(rating_avg: avg)
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
      if @post.reviews_count == 0:
        avg = 0
      else
        avg = (@post.rating_avg * (@post.reviews_count + 1)) / @post.reviews_count
      end  
      @post.update!(rating_avg: avg)

      render json: {notice: "리뷰를 삭제하셨습니다."}, status: :ok
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      render json: {error: e}, status: :bad_request
    end
  end

  private

  def review_params
    params.require(:review).permit(:detail, :rating, :booking_id)
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
end
