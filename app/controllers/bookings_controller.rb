class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_post, only: %i(create complete)
  before_action :load_booking, only: %i(show complete destroy)
  before_action :check_owner, only: %i(show destroy)

  def index
    @bookings = params[:received]=="true" ? current_user.received_bookings : current_user.bookings

    render json: @bookings, status: :ok
  end

  def show
    render json: { booking: @booking }, status: :ok
  end

  def create
    if current_user == @post.user 
      render json: {error: "자신의 게시글에 대한 예약은 생성할 수 없습니다."}, status: :bad_request
    else
      @booking = current_user.bookings.create! booking_params

      @post.unable!

      render json: @booking, status: :ok
    end
  end

  def complete
    begin
      @booking.update!(acceptance: :completed)
      @post.able!
      render json: {notice: "반납이 완료되었습니다."}, status: :ok
    rescue => e
      render json: {error: e.errors.full_messages}, status: :bad_request
    end
  end

  # booking 모델을 삭제하므로 일반적인 경우가 아닐 시 사용하지 않습니다.
  # 예약 기간이 종료되었을 경우 booking.acceptance를 변경해야합니다.
  def destroy
    begin
      @booking.destroy!
      render json: {notice: "예약을 삭제하셨습니다."}, status: :ok
    rescue => e
      render json: {error: e.errors.full_messages}, status: :bad_request
    end    
  end

  private
  def load_post
    begin
      @post = Post.find(params[:booking][:post_id])
    rescue => e
      render json: {error: "없는 게시글입니다."}, status: :bad_request
    end
  end

  def load_booking
    begin
      @booking = Booking.find(params[:id])
    rescue => e
      render json: {error: "없는 예약입니다."}, status: :bad_request
    end
  end

  def check_owner
    if @booking.user != current_user && @booking.post.user != current_user
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end

  def booking_params
    params[:booking][:end_at] = params[:booking][:start_at] if params.dig(:booking, :end_at).blank?
    book_params = params.require(:booking).permit(:post_id, :start_at, :end_at)
    lent_day = book_params[:end_at].to_datetime.day - book_params[:start_at].to_datetime.day + 1
    extra = {
      post_id: @post.id,
      title: @post.title,
      body: @post.body,
      lent_day: lent_day,
      price: @post.price * lent_day,
      acceptance: :accepted
    }
    return book_params.merge(extra)
  end
end
