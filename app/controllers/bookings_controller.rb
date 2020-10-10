class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_post, only: %i(create)
  before_action :load_booking, only: %i(index)

  def index

  end

  def create
    @booking = current_user.bookings.create! booking_params
  end

  private
  def load_post
    begin
      @post = Post.find(params[:post_id])
    rescue => e
      render json: {error: "없는 게시글입니다."}, status: :bad_request
    end
  end

  def load_booking
    begin
      @booking = Post.find(params[:id])
    rescue => e
      render json: {error: "없는 예약입니다."}, status: :bad_request
    end
  end

  def booking_params
    params[:booking][:end_at] = params[:booking][:start_at] if params.dig(:booking, :end_at).blank?
    book_params = params.require(:booking).permit(:post_id, :start_at, :end_at)
    extra = {
      post_id: @post.id,
      title: @post.title,
      body: @post.body,
      price: @post.price * (book_params[:end_at].to_datetime.day - book_params[:start_at].to_datetime.day + 1),
      acceptance: :accepted
    }
    return book_params.merge(extra)
  end
end
