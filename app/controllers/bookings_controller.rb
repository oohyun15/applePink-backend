class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_post, only: %i(new create)
  before_action :load_booking, only: %i(show accept complete destroy)
  before_action :check_owner, only: %i(show accept complete destroy)

  def index
    @bookings = params[:received]=="true" ? current_user.received_bookings : current_user.bookings

    # status: before
    @bookings = @bookings.where(acceptance: %i(waiting accepted rejected)) if params[:status] == "before"
    
    # status: after
    @bookings = @bookings.where(acceptance: %i(completed rent)) if params[:status] == "after"

    render json: @bookings, status: :ok, scope: {params: create_params}, user_id: current_user.id
  end

  def new
    @booking = @post.bookings.find_by(user_id: current_user.id, acceptance: :waiting)
    render json: @booking.present? ? @booking : nil, status: :ok, scope: {params: create_params}, user_id: current_user.id
  end

  def show
    render json: @booking, status: :ok, scope: {params: create_params}, user_id: current_user.id
  end

  def create
    if current_user == @post.user
      Rails.logger.error "ERROR: 자신의 게시글에 대한 예약은 생성할 수 없습니다. #{log_info}"
      return render json: {error: "자신의 게시글에 대한 예약은 생성할 수 없습니다."}, status: :bad_request
    else
      begin
        if @booking = @post.bookings.find_by(user_id: current_user.id, acceptance: :waiting)
          @booking.update! booking_params
        else
          @booking = current_user.bookings.create! booking_params
        end
        return render json: @booking, status: :ok, scope: {params: create_params}, user_id: current_user.id
      rescue => e
        Rails.logger.error "ERROR: #{@booking.errors&.first&.last} #{log_info}"
        return render json: {error: @booking.errors&.first&.last}, status: :bad_request
      end
    end
  end

  def accept
    @post = @booking.post

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

      return render json: @booking, status: :ok, scope: {params: create_params}, user_id: current_user.id
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      return render json: {error: e}, status: :bad_request
    end
  end

  def complete
    @post = @booking.post

    unless @booking.rent?
      Rails.logger.error "ERROR: Couldn't complete booking. booking acceptance: #{@booking.acceptance}. #{log_info}"
      return render json: {error: "Couldn't complete booking. booking acceptance: #{@booking.acceptance}."}, status: :bad_request
    end
    begin
      @booking.update!(acceptance: :completed)
      @post.rent_count += 1
      @post.able!
      return render json: @booking, status: :ok, scope: {params: create_params}, user_id: current_user.id
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      return render json: {error: e}, status: :bad_request
    end
  end

  def list
    booking_ids = current_user.bookings.ids + current_user.received_bookings.ids
    if params[:type] == "rent"
      @bookings = Booking.all.where(id: booking_ids)&.rent
    elsif params[:type] == "completed"
      @bookings = Booking.all.where(id: booking_ids)&.completed
    else
      Rails.logger.error "ERROR: 올바르지 않은 파라미터입니다. #{log_info}"
      return render json: {error: "올바르지 않은 파라미터입니다."}, status: :bad_request
    end

    return render json: @bookings, status: :ok, scope: {params: create_params}, user_id: current_user.id
  end

  # booking 모델을 삭제하므로 일반적인 경우가 아닐 시 사용하지 않습니다.
  # 예약 기간이 종료되었을 경우 booking.acceptance를 변경해야합니다.
  def destroy
    begin
      @booking.destroy!
      return render json: {notice: "예약을 삭제하셨습니다."}, status: :ok
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      return render json: {error: e}, status: :bad_request
    end    
  end

  private
  def load_post
    begin
      @post = Post.find(params[:booking][:post_id]) rescue Post.find(params[:post_id])
    rescue => e
      Rails.logger.error "ERROR: 없는 게시글입니다. #{log_info}"
      return render json: {error: "없는 게시글입니다."}, status: :bad_request
    end
  end

  def load_booking
    begin
      @booking = Booking.find(params[:id])
    rescue => e
      Rails.logger.error "ERROR: 없는 예약입니다. #{log_info}"
      render json: {error: "없는 예약입니다."}, status: :bad_request
    end
  end

  def check_owner
    if @booking.user != current_user && @booking.post.user != current_user
      Rails.logger.error "ERROR: 예약 확인할 권한이 없습니다. #{log_info}"
      return render json: { error: "unauthorized" }, status: :unauthorized
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
      product: @post.product,
      lent_day: lent_day,
      price: @post.price * lent_day,
      acceptance: :waiting,
      provider_name: @post.user.name,
      consumer_name: current_user.name
    }
    return book_params.merge(extra)
  end
end
