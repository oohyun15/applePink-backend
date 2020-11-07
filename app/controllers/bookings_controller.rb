class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_post, only: %i(create update accept complete)
  before_action :load_booking, only: %i(show update accept complete destroy)
  before_action :check_owner, only: %i(show update accept complete destroy)

  def index
    @bookings = params[:received]=="true" ? current_user.received_bookings : current_user.bookings

    render json: @bookings, status: :ok, scope: {params: create_params}
  end

  def show
    render json: @booking, status: :ok, scope: {params: create_params}
  end

  def create
    if current_user == @post.user
      Rails.logger.debug "ERROR: 자신의 게시글에 대한 예약은 생성할 수 없습니다."
      render json: {error: "자신의 게시글에 대한 예약은 생성할 수 없습니다."}, status: :bad_request
    else
      @booking = current_user.bookings.create! booking_params

      render json: @booking, status: :ok, scope: {params: create_params}
    end
  end

  def update
    begin
      @booking.update! booking_params
    rescue => e
      Rails.logger.debug "ERROR: 올바르지 않은 파라미터입니다."
      render json: {error: "올바르지 않은 파라미터입니다."}, status: :bad_request
    end

    render json: @booking, status: :ok, scope: {params: create_params}
  end

  def accept
    acceptance_list = %w(accepted rejected)
    return render json: {error: "Unpermitted parameter."}, status: :bad_request unless acceptance_list.include? params[:booking][:acceptance]
    begin
      @booking.send(params[:booking][:acceptance] + "!")
      
      case params[:booking][:acceptance]
      when "accepted"
        @post.unable! if @post.able?
        @booking.update!(contract: @post.contract)

      when "rejected"
        @post.able! if @post.unable?        
      end

      render json: @booking, status: :ok, scope: {params: create_params}
    rescue => e
      Rails.logger.debug "ERROR: #{e}"
      render json: {error: e}, status: :bad_request
    end
  end

  def complete
    unless @booking.accepted?
      Rails.logger.debug "ERROR: Couldn't complete booking. booking acceptance: #{@booking.acceptance}."
      return render json: {error: "Couldn't complete booking. booking acceptance: #{@booking.acceptance}."}, status: :bad_request
    end
    begin
      @booking.update!(acceptance: :completed)
      @post.rent_count += 1
      @post.able!
      render json: @booking, status: :ok, scope: {params: create_params}
    rescue => e
      Rails.logger.debug "ERROR: #{e}"
      render json: {error: e}, status: :bad_request
    end
  end

  # booking 모델을 삭제하므로 일반적인 경우가 아닐 시 사용하지 않습니다.
  # 예약 기간이 종료되었을 경우 booking.acceptance를 변경해야합니다.
  def destroy
    begin
      @booking.destroy!
      render json: {notice: "예약을 삭제하셨습니다."}, status: :ok
    rescue => e
      Rails.logger.debug "ERROR: #{e}"
      render json: {error: e}, status: :bad_request
    end    
  end

  private
  def load_post
    begin
      @post = Post.find(params[:booking][:post_id])
    rescue => e
      Rails.logger.debug "ERROR: 없는 게시글입니다."
      render json: {error: "없는 게시글입니다."}, status: :bad_request
    end
  end

  def load_booking
    begin
      @booking = Booking.find(params[:id])
    rescue => e
      Rails.logger.debug "ERROR: 없는 예약입니다."
      render json: {error: "없는 예약입니다."}, status: :bad_request
    end
  end

  def check_owner
    if @booking.user != current_user && @booking.post.user != current_user
      Rails.logger.debug "ERROR: 예약 확인할 권한이 없습니다."
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end

  def booking_params
    params[:booking][:end_at] = params[:booking][:start_at] if params.dig(:booking, :end_at).blank?
    book_params = params.require(:booking).permit(:post_id, :start_at, :end_at)
    lent_day = (params[:booking][:start_at].to_datetime...params[:booking][:end_at].to_datetime).count
    extra = {
      post_id: @post.id,
      title: @post.title,
      body: @post.body,
      lent_day: lent_day,
      price: @post.price * lent_day,
      acceptance: :waiting
    }
    return book_params.merge(extra)
  end
end
